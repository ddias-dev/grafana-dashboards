local g = import '../g.libsonnet';

local panels = import '../common/panels.libsonnet';
local queries = import '../common/queries.libsonnet';
local variables = import '../common/variables.libsonnet';

g.dashboard.new('{{title}}')
+ g.dashboard.withUid('{{service_name}}')
+ g.dashboard.withDescription('This is a auto-generated dashboard to overview {{service_name}} container metrics.')
+ g.dashboard.withVariables([
  variables.datasource,
  variables.resolution,
  variables.service,
])
+ g.dashboard.withPanels([
  // Information Row
  panels.row.collapse('Information', [], false, { h: 1, w: 24, x: 0, y: 0 }),
  panels.table.containerResources({ h: 3, w: 24, x: 0, y: 1 }),
  panels.table.containerPods({ h: 5, w: 24, x: 0, y: 4 }),
  // Resources Row
  panels.row.collapse('Resources', [], false, { h: 1, w: 24, x: 0, y: 9 }),
  panels.barGauge.vertical('Current CPU Usage', [
    queries.containerCpuRequestUsagePercent,
    queries.containerCpuLimitsUsagePercent,
  ], { h: 8, w: 3, x: 0, y: 10 }),
  panels.timeSeries.thresholdsHeatArea('CPU Usage per Requests & Limits', [
    queries.containerCpuRequestUsagePercent,
    queries.containerCpuLimitsUsagePercent,
  ], { h: 8, w: 9, x: 3, y: 10 }),
  panels.barGauge.vertical('Current RAM Usage', [
    queries.containerRamRequestUsagePercent,
    queries.containerRamLimitsUsagePercent,
  ], { h: 8, w: 3, x: 12, y: 10 }),
  panels.timeSeries.thresholdsHeatArea('RAM Usage per Requests & Limits', [
    queries.containerRamRequestUsagePercent,
    queries.containerRamLimitsUsagePercent,
  ], { h: 8, w: 9, x: 15, y: 10 }),
  panels.timeSeries.coresNBytes('CPU / RAM Usage', [queries.containerCpuUsage, queries.containerRamUsage], { h: 8, w: 12, x: 0, y: 18 }),
  panels.timeSeries.seconds('CPU Throttled', [queries.containerCpuThrottled], { h: 8, w: 12, x: 12, y: 18 }),
  // Network Row
  panels.row.collapse('Network', [], false, { h: 1, w: 24, x: 0, y: 26 }),
  panels.timeSeries.bytes('Bandwidth', [queries.containerNetworkReceiveBytes, queries.containerNetworkTransmitBytes], { h: 8, w: 12, x: 0, y: 27 }, false),
  panels.timeSeries.packetsPerSec('Packets Rate', [queries.containerNetworkReceivePackets, queries.containerNetworkTransmitPackets], { h: 8, w: 12, x: 12, y: 27 }, false),
  panels.timeSeries.packetsPerSec('Packets Dropped', [queries.containerNetworkReceivePacketsDropped, queries.containerNetworkTransmitPacketsDropped], { h: 8, w: 12, x: 0, y: 35 }, false),
  panels.timeSeries.packetsPerSec('Errors', [queries.containerNetworkReceiveErrors, queries.containerNetworkTransmitErrors], { h: 8, w: 12, x: 12, y: 35 }, false),
])
+ g.dashboard.withTags(['Container'])
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withEditable(false)
+ g.dashboard.time.withFrom('now-24h')
+ g.dashboard.time.withTo('now')
