class DaemonClusterMemory < Scout::Plugin
  def build_report
    ps_command = option('ps_command') || 'ps axucww'
    ps_output = `#{ps_command}`.to_a

    fields = ps_output.first.downcase.split
    memory_index = fields.index('rss')

    pid_index = fields.index('pid')

    pid_dir = option('pid_dir')
    unless File.exist?(pid_dir)
      error("PID directory not found", "#{pid_dir} was not found on the file system")
      return
    end

    process_name = option('process_name')
    report_data = {}
    Dir[File.join(pid_dir, "#{process_name}*.pid")].each do |pid_file|
      process = pid_file.reverse.split('_')[0].split('.')[1].reverse
      pid = File.read(pid_file).chomp

      ps_line = ps_output.detect {|line| line.split[pid_index] == pid}
      memory = ps_line ? Float(ps_line.split[memory_index]) / 1024 : nil

      p_name = process_name ||= "Process"
      report_data["#{p_name} #{process}"] = memory
    end

    report(report_data)
  end
end
