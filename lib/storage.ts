import { RemovalPolicy } from 'aws-cdk-lib';
import { BlockPublicAccess, Bucket } from 'aws-cdk-lib/aws-s3';
import { BucketDeployment, Source } from 'aws-cdk-lib/aws-s3-deployment';
import { Construct } from 'constructs';

type StorageProps = {
  environment: string;
};

export class Storage extends Construct {
  private bucket: Bucket;

  constructor(scope: Construct, id: string, props: StorageProps) {
    super(scope, id);

    const { environment } = props;

    this.bucket = new Bucket(this, 'Bucket', {
      bucketName: `grafana-dashboards-${environment}`,
      publicReadAccess: false,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      versioned: true,
      autoDeleteObjects: true,
      removalPolicy: RemovalPolicy.DESTROY
    });

    new BucketDeployment(this, 'BucketDeployment', {
      sources: [Source.asset('./dashboards/bin')],
      include: ['*.json'],
      destinationBucket: this.bucket,
      destinationKeyPrefix: 'templates',
      contentType: 'text/plain'
    });
  }

  getBucket(): Bucket {
    return this.bucket;
  }
}
