import * as cdk from 'aws-cdk-lib';

import { platformAccounts, tags } from '../config';
import { GrafanaDashboard } from '../lib';

const app = new cdk.App();

platformAccounts.forEach((environment) => {
  new GrafanaDashboard(app, environment, { tags });
});
