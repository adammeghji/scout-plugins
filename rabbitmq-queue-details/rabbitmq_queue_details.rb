class RabbitmqOverall < Scout::Plugin
  QUEUE_INFO_ITEMS = %w(name messages_ready messages_unacknowledged messages_uncommitted messages acks_uncommitted consumers transactions memory)

  def build_report
    rabbitmqctl_script = @options['rabbitmqctl'] ||
                         '/opt/local/lib/erlang/lib/rabbitmq_server-1.5.0/sbin/rabbitmqctl'
    queue_name = @options['queue']

    unless queue_name
      error("Queue name not specified", "You must specify the queue to get details for.")
      return
    end

    queue_stats_line = get_queue_stats_line(rabbitmqctl_script, queue_name)

    unless queue_stats_line
      error("\"#{queue_name}\" queue not found", "Please check the queue name for potential errors.")
      return
    end

    report(extract_stats(queue_stats_line))
  end

  private
    def get_queue_stats_line(rabbitmqctl_script, queue_name)
      all_queue_stats = `#{rabbitmqctl_script} -q list_queues #{QUEUE_INFO_ITEMS.join(' ')}`.to_a
      all_queue_stats.detect do |line|
        line.split[0] == queue_name
      end
    end

    def extract_stats(queue_stats_line)
      queue_stats = queue_stats_line.split

      report_data = {}
      QUEUE_INFO_ITEMS.each_with_index do |item, i|
        next if item == 'name'
        report_data[item] = queue_stats[i]
      end
      report_data
    end
end
