import { StackProps } from 'aws-cdk-lib';

export enum Environment {
  development = 'development',
  production = 'production'
}

export type GrafanaEnvironment =
  | Environment.development
  | Environment.production;

const Account: {
  [x in GrafanaEnvironment]: string;
} = {
  production: '000000000000',
  development: '000000000000'
};

export const platformAccounts: GrafanaEnvironment[] = [
  Environment.development,
  Environment.production
];

export const platformAccountIds: string[] = platformAccounts.map(
  (e) => Account[e]
);

export const getCDKAccount = (
  env: GrafanaEnvironment,
  region?: string
): StackProps['env'] => ({
  account: Account[env],
  region: region ?? 'us-east-1'
});
