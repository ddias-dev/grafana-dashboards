local g = import '../g.libsonnet';

local pq = g.query.prometheus;

local var = import '../common/variables.libsonnet';

{
  local playlist = g.playlist,

  local base(title, expr) =
    pq.new('$' + var.datasource.name, expr)
    + pq.withLegendFormat(title)
    + pq.withEditorMode('code'),

  local timeSeries(title, expr) =
    base(title, expr)
    + pq.withRange(true),

  local table(title, expr) =
    base(title, expr)
    + pq.withFormat('table')
    + pq.withInstant(true),

  local withInterval(title, expr) =
    timeSeries(title, expr)
    // The withIntervalFactor is not correctly adding the interval property to the current
    // Amazon Managed Grafana v8.4.7, here is a workaround to add interval to a Prometheus query.
    + playlist.withInterval('$resolution'),

  // Kubernertes Overview
  globalCpuLimits:
    timeSeries('Limits', 'sum(kube_pod_container_resource_limits{resource="cpu"}) / sum(machine_cpu_cores)'),

  globalCpuReal:
    timeSeries('Real', 'avg(1-rate(node_cpu_seconds_total{mode="idle"}[$__rate_interval]))'),

  globalCpuRequets:
    timeSeries('Requests', 'sum(kube_pod_container_resource_requests{resource="cpu"}) / sum(machine_cpu_cores)'),

  globalRamLimits:
    timeSeries('Limits', 'sum(kube_pod_container_resource_limits{resource="memory"}) / sum(machine_memory_bytes)'),

  globalRamReal:
    timeSeries('Real', 'sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes)'),

  globalRamRequets:
    timeSeries('Requests', 'sum(kube_pod_container_resource_requests{resource="memory"}) / sum(machine_memory_bytes)'),

  countNamespaces:
    timeSeries('Namespaces', 'sum(kube_namespace_labels)'),

  countRunningPods:
    timeSeries('Running Containers', 'sum(kube_pod_container_status_running)'),

  countServices:
    timeSeries('Services', 'sum(kube_service_info)'),

  countEndpoints:
    timeSeries('Endpoints', 'sum(kube_endpoint_info)'),

  countDeployments:
    timeSeries('Deployments', 'sum(kube_deployment_labels)'),

  countStatefulsets:
    timeSeries('Statefulsets', 'sum(kube_statefulset_labels)'),

  countDaemonsets:
    timeSeries('Daemonsets', 'sum(kube_statefulset_labels)'),

  countPersistentVolumeClaims:
    timeSeries('Persistent Volume Claims', 'sum(kube_persistentvolumeclaim_info)'),

  countHpas:
    timeSeries('Horizontal Pod Autoscalers', 'sum(kube_hpa_labels)'),

  countConfigmaps:
    timeSeries('Configmaps', 'sum(kube_configmap_info)'),

  countSecrets:
    timeSeries('Secrets', 'sum(kube_secret_info)'),

  countNetworkPolicies:
    timeSeries('Network Policies', 'sum(kube_networkpolicy_labels)'),

  countNodes:
    timeSeries('Nodes', 'count(count by (node) (kube_node_info))'),

  countCpuReal:
    timeSeries('Real', 'sum(1-rate(node_cpu_seconds_total{mode="idle"}[$__rate_interval]))'),

  countCpuRequests:
    timeSeries('Requests', 'sum(kube_pod_container_resource_requests{resource="cpu"})'),

  countCpuLimits:
    timeSeries('Limits', 'sum(kube_pod_container_resource_limits{resource="cpu"})'),

  countCpuTotal:
    timeSeries('Total', 'sum(machine_cpu_cores)'),

  countRamReal:
    timeSeries('Real', 'sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes)'),

  countRamRequests:
    timeSeries('Requests', 'sum(kube_pod_container_resource_requests{resource="memory"})'),

  countRamLimits:
    timeSeries('Limits', 'sum(kube_pod_container_resource_limits{resource="memory"})'),

  countRamTotal:
    timeSeries('Total', 'sum(machine_memory_bytes)'),

  countTotalPods:
    timeSeries('Total Pods', 'sum(kube_pod_info)'),

  countQosPods:
    timeSeries('{{ qos_class }} pods', 'sum(kube_pod_status_qos_class) by (qos_class)'),

  countPodStatus:
    timeSeries('{{ reason }}', 'sum(kube_pod_status_reason) by (reason)'),

  // Kubernertes Resources
  clusterCpuUtilisation:
    withInterval('CPU usage in %', 'avg(1-rate(node_cpu_seconds_total{mode="idle"}[$__rate_interval]))'),

  clusterMemoryUtilisation:
    withInterval('Memory usage in %', 'sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes)'),

  cpuUtilisationByNamespace:
    withInterval('{{ namespace }}', 'sum(rate(container_cpu_usage_seconds_total{image!=""}[$__rate_interval])) by (namespace)'),

  memoryUtilisationByNamespace:
    withInterval('{{ namespace }}', 'sum(container_memory_working_set_bytes{image!=""}) by (namespace)'),

  cpuUtilisationByInstace:
    withInterval('{{ node }}', 'avg(1-rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)'),

  memoryUtilisationByInstace:
    withInterval('{{ instance }}', 'sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) by (instance)'),

  cpuThrottleSecsByNamespace:
    withInterval('{{ namespace }}', 'sum(rate(container_cpu_cfs_throttled_seconds_total{image!=""}[$__rate_interval])) by (namespace) > 0'),

  cpuThrottlePercByInstance:
    withInterval('{{ instance }}', 'sum(increase(container_cpu_cfs_throttled_periods_total{container!=""}[$__rate_interval])) by (instance) / sum(increase(container_cpu_cfs_periods_total[$__rate_interval])) by (instance)'),

  // Kubernertes Network
  networkTrafficRecivedByDevice:
    withInterval('Received : {{ device }}', 'sum(rate(node_network_receive_bytes_total{device!~"lxc.*|veth.*"}[$__rate_interval])) by (device)'),

  networkTrafficTransmittedByDevice:
    withInterval('Transmitted : {{ device }}', '- sum(rate(node_network_transmit_bytes_total{device!~"lxc.*|veth.*"}[$__rate_interval])) by (device)'),

  networkTrafficRecivedByNamspace:
    withInterval('Received : {{ namespace }}', 'sum(rate(container_network_receive_bytes_total[$__rate_interval])) by (namespace)'),

  networkTrafficTransmittedByNamspace:
    withInterval('Transmitted : {{ namespace }}', '- sum(rate(container_network_transmit_bytes_total[$__rate_interval])) by (namespace)'),

  networkTrafficRecivedByInstance:
    withInterval('Received : {{ instance }}', 'sum(rate(node_network_receive_bytes_total[$__rate_interval])) by (instance)'),

  networkTrafficTransmittedByInstance:
    withInterval('Transmitted : {{ instance }}', '- sum(rate(node_network_transmit_bytes_total[$__rate_interval])) by (instance)'),

  networkTrafficReceivedNoLoopbackByInstance:
    withInterval('Received : {{ instance }}', 'sum(rate(node_network_receive_bytes_total{device!~"lxc.*|veth.*|lo"}[$__rate_interval])) by (instance)'),

  networkTrafficTransmittedNoLoopbackByInstance:
    withInterval('Received : {{ instance }}', '- sum(rate(node_network_transmit_bytes_total{device!~"lxc.*|veth.*|lo"}[$__rate_interval])) by (instance)'),

  networkTrafficReceivedLoopbackByInstance:
    withInterval('Received : {{ instance }}', 'sum(rate(node_network_receive_bytes_total{device="lo"}[$__rate_interval])) by (instance)'),

  networkTrafficTransmittedLoopbackByInstance:
    withInterval('Received : {{ instance }}', '- sum(rate(node_network_transmit_bytes_total{device="lo"}[$__rate_interval])) by (instance)'),

  networkPkgDroppedReceive:
    withInterval('Packets dropped (receive)', 'sum(rate(node_network_receive_drop_total[$__rate_interval]))'),

  networkPkgDroppedTransmit:
    withInterval('Packets dropped (transmit)', '- sum(rate(node_network_transmit_drop_total[$__rate_interval]))'),

  local cpuUsageExpr = 'sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{container="$service"})',
  local ramUsageExpr = 'sum(container_memory_working_set_bytes{container="$service"})',

  local containerResourceExpr(mechanism, resource) =
    'sum(kube_pod_container_resource_' + std.asciiLower(mechanism) + '{resource="' + std.asciiLower(resource) + '", container="$service"})',

  local containerResourceTable(mechanism, resource) =
    table(resource + ' ' + mechanism, containerResourceExpr(mechanism, resource)),

  local containerResourceUsagePercent(mechanism, resource, resourceExpr) =
    timeSeries(mechanism, resourceExpr + ' / ' + containerResourceExpr(mechanism, resource)),

  containerRunningPodTable:
    table('Running Pod(s)', 'sum(kube_pod_container_status_running{container="$service"})'),

  containerCpuUsage:
    timeSeries('CPU', cpuUsageExpr),

  containerCpuUsageTable:
    table('CPU', cpuUsageExpr),

  containerCpuRequestsTable:
    containerResourceTable('Requests', 'CPU'),

  containerCpuLimitsTable:
    containerResourceTable('Limits', 'CPU'),

  containerRamUsage:
    timeSeries('RAM', ramUsageExpr),

  containerRamUsageTable:
    table('RAM', ramUsageExpr),

  containerRamRequestsTable:
    containerResourceTable('Requests', 'Memory'),

  containerRamLimitsTable:
    containerResourceTable('Limits', 'Memory'),

  containerCpuRequestUsagePercent:
    containerResourceUsagePercent('Requests', 'CPU', cpuUsageExpr),

  containerCpuLimitsUsagePercent:
    containerResourceUsagePercent('Limits', 'CPU', cpuUsageExpr),

  containerRamRequestUsagePercent:
    containerResourceUsagePercent('Requests', 'Memory', ramUsageExpr),

  containerRamLimitsUsagePercent:
    containerResourceUsagePercent('Limits', 'Memory', ramUsageExpr),

  containerPodStatus:
    table('Status', 'kube_pod_container_info{container="$service"} * on (pod) group_right kube_pod_status_phase > 0'),

  containerPodInfo:
    table('Info', 'kube_pod_container_info{container="$service"} * on (pod) group_right kube_pod_info > 0'),

  containerPodQosClass:
    table('QOS Class', 'kube_pod_container_info{container="$service"} * on (pod) group_right kube_pod_status_qos_class > 0'),

  containerPodAge:
    table('Age', 'time() - kube_pod_container_info{container="$service"} * on (pod) group_right kube_pod_status_ready_time'),

  containerCpuThrottled:
    withInterval('Throttled', 'sum(rate(container_cpu_cfs_throttled_seconds_total{container="$service"}[$__rate_interval]))'),

  local containerNetworkFlow(label, flow, unit) =
    withInterval(label, (if (std.asciiLower(flow) == 'transmit') then '- ' else '') + 'sum(rate(container_network_' + std.asciiLower(flow) + '_' + std.asciiLower(unit) + '_total{pod=~"$service.*"}[$__rate_interval]))'),

  containerNetworkReceiveBytes:
    containerNetworkFlow('Received', 'receive', 'bytes'),

  containerNetworkTransmitBytes:
    containerNetworkFlow('Transmitted', 'transmit', 'bytes'),

  containerNetworkReceivePackets:
    containerNetworkFlow('Received', 'receive', 'packets'),

  containerNetworkTransmitPackets:
    containerNetworkFlow('Transmitted', 'transmit', 'packets'),

  containerNetworkReceivePacketsDropped:
    containerNetworkFlow('Received', 'receive', 'packets_dropped'),

  containerNetworkTransmitPacketsDropped:
    containerNetworkFlow('Transmitted', 'transmit', 'packets_dropped'),

  containerNetworkReceiveErrors:
    containerNetworkFlow('Received', 'receive', 'errors'),

  containerNetworkTransmitErrors:
    containerNetworkFlow('Transmitted', 'transmit', 'errors'),
}
