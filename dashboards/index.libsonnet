local k8sResourcesCluster = import './resources/cluster.libsonnet';
local k8sResourcesContainer = import './resources/container.libsonnet';

{
  'k8s-resources-cluster.json': k8sResourcesCluster,
  'k8s-resources-container.json': k8sResourcesContainer,
}
