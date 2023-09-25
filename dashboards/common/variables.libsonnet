local g = import '../g.libsonnet';
local var = g.dashboard.variable;

{
  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.generalOptions.showOnDashboard.withNothing(),

  resolution:
    var.interval.new('resolution', ['5m'])
    + var.interval.generalOptions.showOnDashboard.withNothing(),

  service:
    var.textbox.new('service', default='{{service_name}}')
    + var.textbox.generalOptions.showOnDashboard.withNothing(),
}
