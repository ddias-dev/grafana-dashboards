# Grafana Dashboards

Create and manage Grafana Dashboards as code.

## Description

This project aims to create and manage Grafana Dashboards as code, using AWS CDK
Custom resources together with [Grafonnet](https://github.com/grafana/grafonnet)
and
[Grafana HTTP APIs](https://docs.aws.amazon.com/grafana/latest/userguide/Using-Grafana-APIs.html).

Grafonnet is a new library from Grafana that allows users to create and manage
Grafana dashboards using Jsonnet, a data templating language. Grafonnet
simplifies the process of defining dashboards as code, making them easier to
version, share and reuse.

Grafana HTTP APIs are used to interact with Grafana instances and perform
operations such as creating, updating, and deleting dashboards.

AWS CDK Custom resources are used to integrate Grafonnet and Grafana HTTP APIs
with AWS CloudFormation, allowing users to define and deploy Grafana dashboards
as part of their AWS infrastructure.

## Getting Started

### Requirements

- [AWS CLI](https://aws.amazon.com/cli/) - To configure the AWS Credentials.
- [AWS CDK](https://aws.amazon.com/getting-started/guides/setup-cdk/) - To run
  the local commands and deploy the application.
- [Docker](https://docs.docker.com/get-docker/) - To run the local commands and
  deploy the application.
- [nmv](https://github.com/nvm-sh/nvm#installing-and-updating) - to set up
  Node.js v18
- [go-jsonnet](https://github.com/google/go-jsonnet) - Grafonnet uses the
  [Jsonnet](https://jsonnet.org/) programming language.
  > **NOTE**: There is a significant performance issue with the C implementation
  > of Jsonnet. You are strongly recommended to use the newer
  > [go-jsonnet](https://github.com/google/go-jsonnet) Jsonnet implementation.
  > This is also the implementation recommended by the Jsonnet developers
  > themselves. It requires [Go](https://go.dev/doc/install)
- [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler/) - a
  package manager for [Jsonnet](https://jsonnet.org/)

## Local Commands

- `aws sso login` to log in to development/production AWS SSO account
- `npm install` install package.json dependencies
- `npm run clean-packages` perform a npm packages clean up
- `npm run dashboard-gen` generate Grafana Dashboards json models
- `npm run deploy-[dev|prod]` build and deploy this stack to specific
  environment
- `npm run format` run a code formatter for entire application
- `npm run test` perform eslint and jest snapshot testing

## References

- [Grafonnet Docs](https://grafana.github.io/grafonnet/index.html)
