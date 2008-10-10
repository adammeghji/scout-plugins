class SmsStats < Scout::Plugin
  needs 'mysql'

  def build_report
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
        from message_history
       where created_at > DATE_SUB(now(), INTERVAL 5 MINUTE)
    SQL

    results.each_hash do |row|
      report(:MT => row['mt'] || 0, :MO => row['mo'] || 0,
             'Failed MTs' => row['failed_mt'] || 0,
             'Average Transaction Time' => row['avg_transaction_time'],
             'Average Aggregator Time' => row['avg_aggregator_time'])
    end
  end
end
