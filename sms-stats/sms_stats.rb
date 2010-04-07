# Custom monitoring of Interactive Mediums SMS system.
#
# The following statistics are calculated (for the last five minutes of traffic):
#
# MT:: The number of Mobile Terminated (aka, outgoing) messages sent.
# MO:: The number of Mobile Originated (aka, incoming) messages recevied.
# Failed MTs::
#      The number of MTs that were not sent due to a failure
#      from the aggregator.
# Average Transaction Time::
#      The average latency (in seconds) for processing a text message
#      transaction. In other words, this is the total time spent in
#      our system. TM transactions originate either from received MOs
#      (user requests) or system generated MTs (scheduled messages).
#      This average is across all types.
# Average Aggregator Time::
#      The average latency (in seconds) that the aggregator took to
#      process the outgoing MT.
class SmsStats < Scout::Plugin
  needs 'mysql'

  DB_FORMAT = '%Y-%m-%d %H:%M:%S'

  def build_report
    last_run = memory(:last_run)

    # Will calculate message deltas on the next run.
    unless last_run.nil?
      user = option(:user) || 'root'
      password = option(:password)
      host = option(:host) || 'localhost'
      port = option(:port) || 3306
      socket = option(:socket) || '/tmp/mysql.sock'
      database = option(:database)

      mysql = Mysql.connect(host, user, password, database, port.to_i, socket)
      results = mysql.query <<-SQL
        select sum(if(message_type='MT' and error_code is null,1,0)) as mt,
               sum(if(message_type='MO',1,0)) as mo,
               sum(if(message_type = 'MT' and error_code is not null,1,0)) as failed_mt,
               avg(transaction_time) as avg_transaction_time,
               avg(aggregator_time) as avg_aggregator_time
          from recent_messages
         where created_at > '#{last_run.strftime(DB_FORMAT)}'
      SQL

      results.each_hash do |row|
        report(:MT => row['mt'] || 0, :MO => row['mo'] || 0,
               'Failed MTs' => row['failed_mt'] || 0,
               'Average Transaction Time' => row['avg_transaction_time'],
               'Average Aggregator Time' => row['avg_aggregator_time'])
      end
    end

    remember(:last_run, Time.now)
  end
end
