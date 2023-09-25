local g = import '../g.libsonnet';
local queries = import './queries.libsonnet';
local var = import './variables.libsonnet';

{
  local default = {
    panel(panel, title, targets, gridPosition):
      panel.new(title)
      + panel.withTargets(targets)
      + panel.datasource.withType(var.datasource.type)
      + panel.datasource.withUid('$' + var.datasource.type)
      + panel.gridPos.withH(gridPosition.h)
      + panel.gridPos.withW(gridPosition.w)
      + panel.gridPos.withX(gridPosition.x)
      + panel.gridPos.withY(gridPosition.y),
  },

  barGauge: {
    local barGauge = g.panel.barGauge,
    local options = barGauge.options,
    local standardOptions = barGauge.standardOptions,
    local thresholds = standardOptions.thresholds,

    base(title, targets, gridPosition):
      default.panel(barGauge, title, targets, gridPosition)
      + options.withDisplayMode('lcd')
      + standardOptions.withUnit('percentunit')
      + standardOptions.withMin(0)
      + standardOptions.withMax(1)
      + thresholds.withMode('percentage')
      + thresholds.withSteps([
        {
          color: 'green',
          value: null,
        },
        {
          color: 'yellow',
          value: 60,
        },
        {
          color: 'red',
          value: 75,
        },
      ]),


    horizontal(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + options.withOrientation('horizontal'),

    vertical(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + options.withOrientation('vertical'),
  },

  row: {
    local row = g.panel.row,

    collapse(title, targets, collapsed, gridPosition):
      row.new(title)
      + row.withPanels(targets)
      + row.withCollapsed(collapsed)
      + row.gridPos.withH(gridPosition.h)
      + row.gridPos.withW(gridPosition.w)
      + row.gridPos.withX(gridPosition.x)
      + row.gridPos.withY(gridPosition.y),
  },

  stat: {
    local stat = g.panel.stat,
    local options = stat.options,
    local thresholds = stat.standardOptions.thresholds,
    local standardOptions = stat.standardOptions,

    single(title, targets, gridPosition):
      default.panel(stat, title, targets, gridPosition)
      + options.withGraphMode('none')
      + options.withColorMode('value')
      + options.withTextMode('value')
      + options.reduceOptions.withCalcs(['last'])
      + thresholds.withMode('absolute')
      + thresholds.withSteps([{ color: 'blue' }]),

    multi(title, targets, gridPosition):
      default.panel(stat, title, targets, gridPosition)
      + options.withGraphMode('none')
      + options.withJustifyMode('center')
      + options.reduceOptions.withCalcs(['mean'])
      + thresholds.withMode('absolute')
      + thresholds.withSteps([{ color: 'white' }]),

    multiBytes(title, targets, gridPosition):
      self.multi(title, targets, gridPosition)
      + standardOptions.withUnit('bytes'),
  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local fieldOverride = timeSeries.fieldOverride,
    local options = timeSeries.options,
    local legend = options.legend,
    local tooltip = options.tooltip,
    local queryOptions = timeSeries.queryOptions,
    local standardOptions = timeSeries.standardOptions,
    local color = standardOptions.color,
    local thresholds = standardOptions.thresholds,
    local thresholdStep = timeSeries.thresholdStep,

    base(title, targets, gridPosition):
      default.panel(timeSeries, title, targets, gridPosition)
      + tooltip.withMode('multi')
      + custom.withLineInterpolation('smooth')
      + custom.withLineWidth(2)
      + custom.withFillOpacity(10)
      + custom.withSpanNulls(true)
      + custom.withShowPoints('never'),

    heat(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + legend.withDisplayMode('hidden')
      + custom.withGradientMode('scheme')
      + color.withMode('continuous-GrYlRd'),

    percentHeat(title, targets, gridPosition):
      self.heat(title, targets, gridPosition)
      + standardOptions.withUnit('percentunit')
      + standardOptions.withDecimals(2),

    count(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + custom.withGradientMode('opacity')
      + standardOptions.withUnit('short')
      + legend.withDisplayMode('table')
      + legend.withCalcs(['min', 'max', 'mean'])
      + legend.withPlacement('right')
      + legend.withShowLegend(true)
      + legend.withSortBy('Max')
      + legend.withSortDesc(true),

    bytes(title, targets, gridPosition, noLegend=true):
      self.base(title, targets, gridPosition)
      + custom.withAxisLabel('Bytes')
      + standardOptions.withUnit('bytes')
      + legend.withDisplayMode(if (noLegend) then 'hidden' else 'list'),

    packetsPerSec(title, targets, gridPosition, noLegend=true):
      self.base(title, targets, gridPosition)
      + custom.withAxisLabel('Packets / Sec')
      + standardOptions.withUnit('pps')
      + legend.withDisplayMode(if (noLegend) then 'hidden' else 'list'),

    maxHeat(title, targets, gridPosition, axisLabel):
      self.heat(title, targets, gridPosition)
      + custom.withAxisLabel(axisLabel)
      + queryOptions.withTransformations([
        {
          id: 'configFromData',
          options: {
            configRefId: 'max',
            mappings: [],
          },
        },
      ]),

    bytesMaxHeat(title, targets, gridPosition, axisLabel):
      self.maxHeat(title, targets, gridPosition, axisLabel)
      + standardOptions.withUnit('bytes'),

    thresholdsHeatArea(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + color.withMode('thresholds')
      + custom.withAxisLabel('Percent')
      + custom.withFillOpacity(0)
      + custom.withGradientMode('scheme')
      + custom.withThresholdsStyle({
        mode: 'area',
      })
      + legend.withDisplayMode('hidden')
      + standardOptions.withUnit('percentunit')
      + standardOptions.withMin(0)
      + standardOptions.withMax(1)
      + thresholds.withMode('percentage')
      + thresholds.withSteps([
        thresholdStep.withColor('red'),
        thresholdStep.withColor('yellow')
        + thresholdStep.withValue(20),
        thresholdStep.withColor('green')
        + thresholdStep.withValue(30),
        thresholdStep.withColor('yellow')
        + thresholdStep.withValue(70),
        thresholdStep.withColor('red')
        + thresholdStep.withValue(80),
      ]),

    coresNBytes(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + custom.withAxisLabel('Cores')
      + standardOptions.withDecimals(4)
      + standardOptions.withOverrides([
        fieldOverride.byRegexp.new('/RAM/')
        + fieldOverride.byRegexp.withPropertiesFromOptions(
          standardOptions.withDecimals('auto')
          + standardOptions.withUnit('bytes')
          + custom.withAxisPlacement('right')
          + custom.withAxisLabel('Bytes')
          + custom.withGradientMode('none')
          + custom.withFillOpacity(0)
        ),
      ]),

    seconds(title, targets, gridPosition):
      self.base(title, targets, gridPosition)
      + custom.withAxisLabel('Seconds')
      + standardOptions.withUnit('s'),
  },

  table: {
    local table = g.panel.table,
    local fieldOverride = table.fieldOverride,
    local options = table.options,
    local queryOptions = table.queryOptions,
    local standardOptions = table.standardOptions,
    local color = standardOptions.color,
    local thresholds = standardOptions.thresholds,
    local thresholdStep = table.thresholdStep,
    local transformation = table.transformation,

    containerResources(gridPosition):
      default.panel(table, 'Ressources', [
        queries.containerRunningPodTable,
        queries.containerCpuUsageTable,
        queries.containerCpuRequestsTable,
        queries.containerCpuLimitsTable,
        queries.containerRamUsageTable,
        queries.containerRamRequestsTable,
        queries.containerRamLimitsTable,
      ], gridPosition)
      + queryOptions.withTransformations([
        transformation.withId('merge'),
        transformation.withId('organize')
        + transformation.withOptions({
          excludeByName: {
            Time: true,
          },
          renameByName: {
            'Value #A': 'Running Pod(s)',
            'Value #B': 'CPU Usage',
            'Value #C': 'CPU Requests',
            'Value #D': 'CPU Limits',
            'Value #E': 'RAM Usage',
            'Value #F': 'RAM Requests',
            'Value #G': 'RAM Limits',
          },
        }),
      ])
      + standardOptions.withOverrides([
        fieldOverride.byRegexp.new('/RAM/')
        + fieldOverride.byRegexp.withPropertiesFromOptions(
          standardOptions.withDecimals(2)
          + standardOptions.withUnit('bytes')
        ),
        fieldOverride.byRegexp.new('/CPU/')
        + fieldOverride.byRegexp.withPropertiesFromOptions(
          standardOptions.withDecimals(4)
        ),
        fieldOverride.byRegexp.new('//')
        + fieldOverride.byRegexp.withProperty('custom.align', 'center')
        + fieldOverride.byRegexp.withProperty('custom.displayMode', 'color-background-solid'),
      ])
      + thresholds.withMode('absolute')
      + thresholds.withSteps([
        thresholdStep.withColor('blue'),
      ]),

    containerPods(gridPosition):
      default.panel(table, 'Pod(s)', [
        queries.containerPodStatus,
        queries.containerPodInfo,
        queries.containerPodQosClass,
        queries.containerPodAge,
      ], gridPosition)
      + queryOptions.withTransformations([
        transformation.withId('merge'),
        transformation.withId('organize')
        + transformation.withOptions({
          excludeByName: {
            Time: true,
            'Value #A': true,
            'Value #B': true,
            'Value #C': true,
            app_kubernetes_io_component: true,
            app_kubernetes_io_instance: true,
            app_kubernetes_io_managed_by: true,
            app_kubernetes_io_name: true,
            app_kubernetes_io_part_of: true,
            app_kubernetes_io_version: true,
            created_by_kind: true,
            created_by_name: true,
            helm_sh_chart: true,
            host_ip: true,
            host_network: true,
            instance: true,
            job: true,
            kubernetes_name: true,
            kubernetes_namespace: true,
            kubernetes_node: true,
            namespace: true,
            phase: false,
            uid: true,
          },
          renameByName: {
            'Value #D': 'Age',
            node: 'Running On',
            phase: 'Status',
            pod: 'Name',
            pod_ip: 'IP',
            qos_class: 'QOS Class',
          },
        }),
      ])
      + color.withMode('fixed')
      + color.withFixedColor('text')
      + standardOptions.withOverrides([
        fieldOverride.byName.new('Age')
        + fieldOverride.byName.withPropertiesFromOptions(
          standardOptions.withUnit('dtdhms')
        ),
        fieldOverride.byName.new('QOS Class')
        + fieldOverride.byName.withPropertiesFromOptions(
          standardOptions.withMappings({
            options: {
              BestEffort: {
                color: 'orange',
                index: 0,
              },
              Burstable: {
                color: 'red',
                index: 1,
              },
              Guaranteed: {
                color: 'green',
                index: 2,
              },
            },
            type: 'value',
          })
        ),
        fieldOverride.byName.new('Status')
        + fieldOverride.byName.withPropertiesFromOptions(
          standardOptions.withMappings({
            options: {
              Error: {
                color: 'red',
                index: 1,
              },
              Running: {
                color: 'green',
                index: 0,
              },
            },
            type: 'value',
          })
        ),
        fieldOverride.byRegexp.new('//')
        + fieldOverride.byRegexp.withProperty('custom.align', 'center')
        + fieldOverride.byRegexp.withProperty('custom.displayMode', 'color-text'),
      ]),
  },
}
