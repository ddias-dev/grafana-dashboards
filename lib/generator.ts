import { Duration } from 'aws-cdk-lib';
import { Runtime } from 'aws-cdk-lib/aws-lambda';
import { S3EventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import { Bucket, EventType } from 'aws-cdk-lib/aws-s3';
import { Provider } from 'aws-cdk-lib/custom-resources';
import { Construct } from 'constructs';
import { grafanaWorkspacePolicy, s3BucketPolicy } from './utils';

type GeneratorProps = {
  account: string;
  region: string;
  workspaceId: string;
  folderUid: string;
  bucket: Bucket;
};

export class Generator extends Construct {
  private provider: Provider;

  constructor(scope: Construct, id: string, props: GeneratorProps) {
    super(scope, id);

    const { account, region, workspaceId, folderUid, bucket } = props;

    const lambda = new NodejsFunction(this, 'handler', {
      functionName: 'grafana-dashboard-generator-trigger',
      timeout: Duration.minutes(1),
      runtime: Runtime.NODEJS_18_X,
      environment: {
        folderUid,
        region,
        workspaceId,
        bucketName: bucket.bucketName
      }
    });

    // Grafana Workspace Policy
    lambda.addToRolePolicy(
      grafanaWorkspacePolicy(
        `arn:aws:grafana:${region}:${account}:/workspaces/*`
      )
    );

    // S3 Bucket Policy
    lambda.addToRolePolicy(s3BucketPolicy(bucket.bucketArn));

    // S3 Event notification
    lambda.addEventSource(
      new S3EventSource(bucket, { events: [EventType.OBJECT_CREATED_PUT] })
    );
  }
}
