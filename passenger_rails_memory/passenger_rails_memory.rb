class PassengerRailsMemory < Scout::Plugin
  def build_report
    cmd  = option(:passenger_memory_stats_command) || "passenger-memory-stats"
    @rails_instance = option(:rails_instance) || "tmb"
    data = `#{cmd} | grep Rails | grep #{@rails_instance}`.to_a
    stats = parse_data(data)
    report(stats)
  end

  def parse_data(data)
    report_data = {}
    report_data["count"] = data.size
    memory = []
    data.each { | instance |
       fields = instance.split
       memory << fields[1].to_f
    }

    report_data["total memory (MB)"] = memory.inject(0){|sum,item| sum + item}
    report_data["max memory (MB)"] = memory.max
    report_data["min memory (MB)"] = memory.min

    report_data
  end
end
