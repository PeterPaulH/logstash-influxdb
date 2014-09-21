#logstash-influxdb
=================

[Logstash](logstash.net) output for [InfluxDB](influxdb.org) based on the existing udp output.

The ruby-code builds a JSON string (see [InfluxDB documentation](influxdb.com/docs/v0.8/api/reading_and_writing_data.html#writing-data-through-json-+-udp)) and sends this through UDP to the InfluxDB server.

###Installation 
Place the file **src/influxdb.rb** into the folder **lib/logstash/outputs**

###InfluxDB-settings
Somewhere in the **config.toml** file:

```
[input_plugins]
  [input_plugins.udp]
    enabled = true
    port = 4444
    database = "<database-name>"
```

###Logstash-settings
In the config-file.

```
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
```

####Name:
An array of the parts of the name of the series in InfluxDB.
This name is created by concattenating the elements of the array with a dot (.) as separator. 

####Columns:
An array of the names of the columns to be used in the InfluxDB series.

####Points:
A hash of the values and the types.
- 'n' = numeric value
- 'f' = floating value
- 'c'(or anything else) = character value 
