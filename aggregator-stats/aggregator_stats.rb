# Custom monitoring of Interactive Mediums SMS system.
#
# MO:: The number of Mobile Originated (aka, incoming) messages recevied.
# Total MTs:: The total number of Mobile Terminated (aka, outgoing) messages sent.
# Success MTs:: The total number of Mobile Terminated (aka, outgoing) messages sent.
# Failed MTs::
#      The number of MTs that were not sent due to a failure
#      from the aggregator.
# Average Aggregator Time::
#      The average latency (in seconds) that the aggregator took to
#      process the outgoing MT.
class AggregatorStats < Scout::Plugin
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
      aggregator_code = option(:aggregator_code)

      mysql = Mysql.connect(host, user, password, database, port.to_i, socket)
      results = mysql.query <<-SQL
        select sum(if(rm.message_type='FU',1,0)) as fu,
               sum(if(rm.message_type='CM',1,0)) as cm,
               sum(if(rm.message_type='MO',1,0)) as mo,
               sum(if(rm.message_type = 'MT',1,0)) as total_mt,
               sum(if(rm.message_type = 'MT' and rm.error_code is null,1,0)) as success_mt,
               sum(if(rm.message_type = 'MT' and rm.error_code is not null,1,0)) as failed_mt,
               avg(rm.aggregator_time) as avg_aggregator_time 
          from recent_messages rm 
          join aggregators a on a.id = rm.aggregator_id 
          where rm.created_at > '#{last_run.utc.strftime(DB_FORMAT)}'
            and rm.txn_id is not null
            and a.code = '#{aggregator_code}'
      SQL

      results.each_hash do |row|
        report(:CM => row['cm'] || 0, 
               :MO => row['mo'] || 0, 
               'Total MTs' => row['total_mt'] || 0,
               'Success MTs' => row['success_mt'] || 0,
               'Failed MTs' => row['failed_mt'] || 0,
               :FU => row['fu'] || 0,
               'Average Aggregator Time' => row['avg_aggregator_time'])
      end
    end

    remember(:last_run, Time.now)
  end
end
