import {
  CreateWorkspaceApiKeyCommand,
  DeleteWorkspaceApiKeyCommand,
  GrafanaClient
} from '@aws-sdk/client-grafana';
import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { Handler } from 'aws-lambda';
import axios, { AxiosRequestConfig } from 'axios';
import { randomUUID } from 'crypto';
import { head, isArray, snakeCase, startCase, stubString } from 'lodash';

const workspaceId = process.env.workspaceId;
const region = process.env.region;
const workspaceUrl = `https://${workspaceId}.grafana-workspace.${region}.amazonaws.com`;

export const handler: Handler = async (event, _context, callback) => {
  try {
    const s3 = event.Records ? event.Records[0].s3 : undefined;
    const toDelete: boolean = event['toDelete'] ?? false;
    const service: string | undefined = event['service'];
    const s3TemplateKey = s3
      ? s3.object.key
      : event.templateKey
      ? event.templateKey
      : 'templates/k8s-resources-container.json';

    // S3 SDK Client
    const s3Client = new S3Client({ region });

    const s3Response = await s3Client.send(
      new GetObjectCommand({
        Bucket: process.env.bucketName,
        Key: s3TemplateKey
      })
    );

    const dashboard = await s3Response.Body?.transformToString('utf-8');
    const versionId = s3Response.VersionId;

    if (dashboard && versionId) {
      // Radom API Key name
      const keyName = randomUUID();

      // Grafana SDK Client
      const gClient = new GrafanaClient({ region });

      // Create Grafana temporary API Key
      const { key } = await gClient.send(
        new CreateWorkspaceApiKeyCommand({
          keyName,
          keyRole: 'ADMIN',
          secondsToLive: 60,
          workspaceId
        })
      );

      const config: AxiosRequestConfig = {
        headers: { Authorization: `Bearer ${key}` }
      };

      // Update a dashboard by service uid
      if (service)
        await deployDashboard(dashboard, service, toDelete, versionId, config);
      // Update all dashboards by tag
      else if (s3) {
        const tag: string = head(JSON.parse(dashboard).tags) ?? stubString();
        const { data } = await getDashboardsByTag(tag, config);
        if (isArray(data) && data.length > 0)
          for (const { uid } of data) {
            if (uid)
              await deployDashboard(
                dashboard,
                uid,
                toDelete,
                versionId,
                config
              );
          }
      }

      // Delete Grafana temporary API Key
      await gClient.send(
        new DeleteWorkspaceApiKeyCommand({ keyName, workspaceId })
      );
    }

    callback(null, 'Grafana Dashboard request completed...');
  } catch (error) {
    // Avoid error to not block the pipeline, but log it.
    callback(null, error);
  }
};

const createDashboard = async (
  dashboard: string,
  service: string,
  versionId: string,
  config: AxiosRequestConfig
) =>
  await axios.post(
    `${workspaceUrl}/api/dashboards/db`,
    {
      dashboard: JSON.parse(
        dashboard
          .replace(new RegExp('{{title}}', 'g'), startCase(service))
          .replace(new RegExp('{{service_name}}', 'g'), service)
          .replace(new RegExp('{{metric_name}}', 'g'), snakeCase(service))
      ),
      folderUid: process.env.folderUid,
      message: versionId,
      overwrite: true
    },
    config
  );

const deleteDashboard = async (uid: string, config: AxiosRequestConfig) =>
  await axios.delete(`${workspaceUrl}/api/dashboards/uid/${uid}`, config);

const getDashboardsByTag = async (tag: string, config: AxiosRequestConfig) =>
  await axios.get(
    `${workspaceUrl}/api/search?folderIds=${process.env.folderUid}&tag=${tag}`,
    config
  );

const deployDashboard = async (
  dashboard: string,
  service: string,
  toDelete: boolean,
  versionId: string,
  config: AxiosRequestConfig
) =>
  toDelete
    ? await deleteDashboard(service, config)
    : await createDashboard(dashboard, service, versionId, config);
