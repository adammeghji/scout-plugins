class PassengerRailsMemory < Scout::Plugin
  def build_report
    cmd  = option(:passenger_memory_stats_command) || "passenger-memory-stats"
    @rails_instance = option(:rails_instance) || "rails"
    data = `#{cmd} | grep Rails | grep #{@rails_instance}`.to_a
    stats = parse_data(data)
    report(stats)
  end

  def parse_data(data)
    report_data = {}
    data.each { | instance | 
       fields = instance.split
       pid = fields[0]
       memory = fields[2]
      report_data["#{@rails_instance}_#{pid}"] = memory
    }
    report_data
  end
end
