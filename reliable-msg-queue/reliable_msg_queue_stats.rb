class ReliableMsgQueueStats < Scout::Plugin
  needs 'mysql'

  def build_report
    user = option(:user) || 'root'
    password = option(:password)
    host = option(:host) || 'localhost'
    port = option(:port) || 3306
    socket = option(:socket) || '/tmp/mysql.sock'
    database = option(:database)

    mysql = Mysql.connect(host, user, password, database, port.to_i, socket)
    results = mysql.query('SELECT queue, count(1) from reliable_msg_queues group by queue')

    results.each do |row|
      report(row[0] => row[1].to_i)
    end
  end
end
