# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "socket"

# Send events over UDP to InfluxDB
#
# Keep in mind that UDP will lose messages.
class LogStash::Outputs::InfluxDB < LogStash::Outputs::Base
  config_name "influxdb"
  milestone 1
  
  # --- Config settings
  # host    The address to send messages to
  # port    The port to send messages on
  # name    The InfluxDB serie to send data to
  # columns
  # point
  config :host,     :validate => :string, :required => true
  config :port,     :validate => :number, :required => true
  config :name,     :validate => :array,  :required => true
  config :columns,  :validate => :array,  :required => true
  config :points,   :validate => :hash,   :required => true

  public
  def register
    @socket = UDPSocket.new
  end

  def receive(event)
    return unless output?(event)
    if event == LogStash::SHUTDOWN
      finished
      return
    end
    # --- Example
    # [ {
    #     "name" : "hd_used",
    #     "columns" : ["value", "host", "mount"],
    #     "points" : [ [23.2, "serverA", "/mnt"] ]
    #   } ]
    @logger.debug("INFLUXDB: Start processing ...")
    aName = []
    aCols = []
    aPnts  = []
    @name.each do |nm|
        aName << event.sprintf(nm)
    end
    @columns.each do |col|
      aCols << '"' + event.sprintf(col) + '"'
    end
    @points.each do |point,type|
      if type == 'n'
        aPnts << event.sprintf(point)
      elsif type == 'f'
        aPnts << event.sprintf(point).to_f
      else
        aPnts << '"' + event.sprintf(point) + '"'
      end
    end
    cName = aName.join(".")
    cCols = aCols.join(",")
    cPnts = aPnts.join(",")
    cMessage = '[ { "name" : "' + cName + '", "columns" : [' + cCols + '], "points" : [[' + cPnts + ']]}]' + "\n"
    @logger.debug("INFLUXDB: sending ", :host => @host, :port => @port, :cMessage => cMessage )
    begin
      @socket.send(cMessage, 0, @host, @port)
    rescue Errno::EPIPE, Errno::ECONNRESET => e
      @logger.warn("INFLUXDB ERROR", :exception => e, :cMessage => cMessage )
    end
  end

end # class LogStash::Outputs::InfluxDB
