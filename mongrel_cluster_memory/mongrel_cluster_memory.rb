class MongrelClusterMemory < Scout::Plugin
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

    report_data = {}
    Dir[File.join(pid_dir, '*.pid')].each do |pid_file|
      port = pid_file.split('.')[1]
      pid = File.read(pid_file)

      ps_line = ps_output.detect {|line| line.split[pid_index] == pid}
      memory = ps_line ? Float(ps_line.split[memory_index]) / 1024 : nil

      report_data["port #{port}"] = memory
    end

    report(report_data)
  end
end
