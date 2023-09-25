local g = import '../g.libsonnet';

local panels = import '../common/panels.libsonnet';
local queries = import '../common/queries.libsonnet';
local variables = import '../common/variables.libsonnet';

g.dashboard.new('Views / Global')
+ g.dashboard.withUid('k8s-views-global')
+ g.dashboard.withDescription('This is a modern global view dashboard for Kubernetes cluster(s).')
+ g.dashboard.withVariables([
  variables.datasource,
  variables.resolution,
])
+ g.dashboard.withPanels([
  // Overview Row
  panels.row.collapse('Overview', [], false, { h: 1, w: 24, x: 0, y: 0 }),
  panels.barGauge.horizontal('Global CPU Usage', [queries.globalCpuReal, queries.globalCpuRequets, queries.globalCpuLimits], { h: 8, w: 6, x: 0, y: 1 }),
  panels.barGauge.horizontal('Global Ram Usage', [queries.globalRamReal, queries.globalRamRequets, queries.globalRamLimits], { h: 8, w: 6, x: 6, y: 1 }),
  panels.stat.single('Nodes', [queries.countNodes], { h: 4, w: 2, x: 12, y: 1 }),
  panels.timeSeries.count('Kubernetes Resources Count', [
    queries.countConfigmaps,
    queries.countDaemonsets,
    queries.countDeployments,
    queries.countEndpoints,
    queries.countHpas,
    queries.countNamespaces,
    queries.countNetworkPolicies,
    queries.countNodes,
    queries.countPersistentVolumeClaims,
    queries.countRunningPods,
    queries.countSecrets,
    queries.countServices,
    queries.countStatefulsets,
  ], { h: 12, w: 10, x: 14, y: 1 }),
  panels.stat.single('Namespaces', [queries.countNamespaces], { h: 4, w: 2, x: 12, y: 5 }),
  panels.stat.multi('CPU Usage', [
    queries.countCpuReal,
    queries.countCpuRequests,
    queries.countCpuLimits,
    queries.countCpuTotal,
  ], { h: 4, w: 6, x: 0, y: 9 }),
  panels.stat.multiBytes('Ram Usage', [
    queries.countRamReal,
    queries.countRamRequests,
    queries.countRamLimits,
    queries.countRamTotal,
  ], { h: 4, w: 6, x: 6, y: 9 }),
  panels.stat.single('Running Pods', [queries.countRunningPods], { h: 4, w: 2, x: 12, y: 9 }),
  panels.timeSeries.count('Kubernetes Pods QoS classes', [
    queries.countQosPods,
    queries.countTotalPods,
  ], { h: 9, w: 12, x: 0, y: 13 }),
  panels.timeSeries.count('Kubernetes Pods Status Reason', [queries.countPodStatus], { h: 9, w: 12, x: 12, y: 13 }),
  // Resources Row
  panels.row.collapse('Resources', [
    panels.timeSeries.percentHeat('Cluster CPU Utilisation', [queries.clusterCpuUtilisation], { h: 8, w: 12, x: 0, y: 23 }),
    panels.timeSeries.percentHeat('Cluster Memory Utilisation', [queries.clusterMemoryUtilisation], { h: 8, w: 12, x: 12, y: 23 }),
    panels.timeSeries.count('CPU Utilisation by Namespace', [queries.cpuUtilisationByNamespace], { h: 8, w: 12, x: 0, y: 31 }),
    panels.timeSeries.count('Memory Utilisation by Namespace', [queries.memoryUtilisationByNamespace], { h: 8, w: 12, x: 12, y: 31 }),
    panels.timeSeries.count('CPU Utilisation by Instance', [queries.cpuUtilisationByInstace], { h: 8, w: 12, x: 0, y: 39 }),
    panels.timeSeries.count('Memory Utilisation by Instance', [queries.memoryUtilisationByInstace], { h: 8, w: 12, x: 12, y: 39 }),
    panels.timeSeries.count('CPU Throttled seconds by namespace', [queries.cpuThrottleSecsByNamespace], { h: 8, w: 12, x: 0, y: 47 }),
    panels.timeSeries.count('CPU Throttling Percent by Instance', [queries.cpuThrottlePercByInstance], { h: 8, w: 12, x: 12, y: 47 }),
  ], true, { h: 1, w: 24, x: 0, y: 22 }),
  // Network Row
  panels.row.collapse('Network', [
    panels.timeSeries.bytes('Total Traffic by Device', [
      queries.networkTrafficRecivedByDevice,
      queries.networkTrafficTransmittedByDevice,
    ], { h: 8, w: 12, x: 0, y: 56 }),
    panels.timeSeries.bytes('Total Traffic by Instance', [
      queries.networkTrafficRecivedByInstance,
      queries.networkTrafficTransmittedByInstance,
    ], { h: 8, w: 12, x: 12, y: 56 }),
    panels.timeSeries.bytes('Total Traffic by Namespace', [
      queries.networkTrafficRecivedByNamspace,
      queries.networkTrafficTransmittedByNamspace,
    ], { h: 8, w: 12, x: 0, y: 64 }),
    panels.timeSeries.bytes('Traffic without Loopback by Instance', [
      queries.networkTrafficReceivedNoLoopbackByInstance,
      queries.networkTrafficTransmittedNoLoopbackByInstance,
    ], { h: 8, w: 12, x: 12, y: 64 }),
    panels.timeSeries.bytes('Loopback Traffic by Instance', [
      queries.networkTrafficReceivedLoopbackByInstance,
      queries.networkTrafficTransmittedLoopbackByInstance,
    ], { h: 8, w: 12, x: 0, y: 72 }),
    panels.timeSeries.bytes('Packets Dropped', [
      queries.networkPkgDroppedReceive,
      queries.networkPkgDroppedTransmit,
    ], { h: 8, w: 12, x: 12, y: 72 }),
  ], true, { h: 1, w: 24, x: 0, y: 55 }),
])
+ g.dashboard.withTags(['Cluster'])
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withEditable(false)
+ g.dashboard.time.withFrom('now-24h')
+ g.dashboard.time.withTo('now')
