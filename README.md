logstash-influxdb
=================

Logstash output for InfluxDB based on the existing udp output.

* Installation 
Place the file src/influxdb.rb into the folder lib/logstash/outputs

* InfluxDB-settings
Somewhere in the config.toml file:

[input_plugins]
  [input_plugins.udp]
    enabled = true
    port = 4444
    database = "<database-name>"

* Logstash-settings

output {
  ...
  influxdb {
    host     => "<hostname or IP of InfluxDB-server>"
    port     => <port of udp-inputs.plugin of InfluxDB-server
    name     => [ "AM", "%{attributename}" ]
    columns  => [ "otap", "hostname", "resourcename", "value" ]
    points   => [ "%{otap}", "c"
                , "%{hostname}", "c"
                , "%{resourcename}", "c"
                , "%{num_value}", "f" ]
  }
  ...
}

Name:

Columns:

Points: