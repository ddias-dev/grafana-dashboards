import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';

import { GrafanaEnvironment, getCDKAccount, getConfig } from '../config';
import { Generator } from './generator';
import { Storage } from './storage';

export class GrafanaDashboard extends Stack {
  constructor(
    scope: Construct,
    environment: GrafanaEnvironment,
    props: StackProps
  ) {
    super(scope, `grafana-dashboards-${environment}`, {
      ...props,
      env: {
        ...getCDKAccount(environment)
      }
    });

    const storage = new Storage(this, 'Storage', { environment });

    const bucket = storage.getBucket();

    const config = getConfig(environment);

    new Generator(this, 'Generator', {
      account: this.account,
      bucket,
      folderUid: config.grafana.folderUid.v2,
      region: this.region,
      workspaceId: config.grafana.workspaceId
    });
  }
}
