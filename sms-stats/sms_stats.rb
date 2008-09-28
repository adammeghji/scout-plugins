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
    results = mysql.query("select sum(if(message_type='MT',1,0)) as mt, sum(if(message_type='MO',1,0)) as mo from message_history where created_at > DATE_SUB(now(), INTERVAL 5 MINUTE) and error_code is null")

    results.each_hash do |row|
     report(:MT => row['mt'].to_i, :MO => row['mo'].to_i)     
    end

  end
  
end