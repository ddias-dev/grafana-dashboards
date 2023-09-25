import { developmentConfig } from './development';
import { Environment, GrafanaEnvironment } from './environments';
import { productionConfig } from './production';

export interface PlatformConfig {
  grafana: {
    workspaceId: string;
    folderUid: {
      v2: string;
    };
  };
}

export function getConfig(env: GrafanaEnvironment | string): PlatformConfig {
  switch (env) {
    case Environment.production:
      return productionConfig;
    case Environment.development:
      return developmentConfig;
    default:
      throw new Error(`Missing or unsupported ENVIRONMENT: ${env}`);
  }
}

export const tags = {
  'ddias-dev:team': 'platform',
  'ddias-dev:project': 'grafana-dashboards'
};
