import { Template } from 'aws-cdk-lib/assertions';
import { App } from 'aws-cdk-lib/core';

import { platformAccounts, tags } from '../config';
import { GrafanaDashboard } from '../lib';

// Snapshot test
test('Snapshot Grafana Dashboards Stack', () => {
  platformAccounts.forEach((environment) => {
    // Instantiate the cdk app
    const app = new App();

    // Create Grafana Dashboards Stack
    const grafanaDashboard = new GrafanaDashboard(app, environment, {
      tags
    });

    // Prepare the stack for assertions
    const template = Template.fromStack(grafanaDashboard);

    // Match with Snapshot
    expect(template.toJSON()).toMatchSnapshot();
  });
});
