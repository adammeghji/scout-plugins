class RabbitmqOverall < Scout::Plugin
  def build_report
    rabbitmqctl_script = @options['rabbitmqctl'] || '/opt/local/lib/erlang/lib/rabbitmq_server-1.5.0/sbin/rabbitmqctl'

    report_data = {}

    connection_stats = `#{rabbitmqctl_script} -q list_connections`.to_a
    report_data['connections'] = connection_stats.size

    queue_stats = `#{rabbitmqctl_script} -q list_queues`.to_a
    report_data['queues'] = queue_stats.size
    report_data['messages'] = queue_stats.inject(0) do |sum, line|
      sum += line.split[1].to_i
    end

    exchange_stats = `#{rabbitmqctl_script} -q list_exchanges`.to_a
    report_data['exchanges'] = exchange_stats.size

    binding_stats = `#{rabbitmqctl_script} -q list_bindings`.to_a
    report_data['bindings'] = binding_stats.size

    report(report_data)
  end
end
