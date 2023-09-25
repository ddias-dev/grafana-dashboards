import { PolicyStatement } from 'aws-cdk-lib/aws-iam';

// S3 Bucket Read Policy
export const s3BucketPolicy = (resourceArn: string) => {
  const policy = new PolicyStatement();
  policy.addActions('s3:Get*');
  policy.addActions('s3:List*');
  policy.addResources(resourceArn);
  policy.addResources(`${resourceArn}/*`);
  return policy;
};

// Lambda Invoke Policy
export const lambdaPolicy = (resourceArn: string) => {
  const policy = new PolicyStatement();
  policy.addActions('lambda:InvokeFunction');
  policy.addActions('s3:List*');
  policy.addResources(resourceArn);
  return policy;
};

// Grafana Workspace Policy
export const grafanaWorkspacePolicy = (resourceArn: string) => {
  const policy = new PolicyStatement();
  policy.addActions('grafana:CreateWorkspaceApiKey');
  policy.addActions('grafana:DeleteWorkspaceApiKey');
  policy.addResources(resourceArn);
  return policy;
};

// CloudFormation Policy
export const cloudformationPolicy = (resourceArn: string) => {
  const policy = new PolicyStatement();
  policy.addActions('cloudformation:GetTemplate');
  policy.addActions('cloudformation:UpdateStack');
  policy.addResources(resourceArn);
  return policy;
};
