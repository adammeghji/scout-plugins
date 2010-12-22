class CouchDBServerStatusPlugin < Scout::Plugin

  OPTIONS = <<-EOS
    couchdb_port:
      label: The port that CouchDB is running on
      default: 5984
    couchdb_host:
      label: The host that CouchDB is running on
      default: http://127.0.0.1
    stats_range:
      label: The time range to fetch stats for in seconds (60, 300, or 900).  Used for CouchDB 0.11 and higher.
      default: 300
  EOS

  needs 'net/http', 'json', 'facets'

  def build_report
    base_url = "#{option(:couchdb_host)}:#{option(:couchdb_port)}/"

    response = JSON.parse(Net::HTTP.get(URI.parse(base_url)))
    version = response['version']
    report(:version => version)

    metrics = %w{database_reads database_writes}

    if version.to_f >= 0.11
      stats = %w{mean max min stddev}
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/request_time?range=#{option(:stats_range)}")))
      stats.each { |stat| report("request_time_#{stat}".to_sym => response['couchdb']['request_time'][stat]) }

      stats = %w{sum mean max stddev}
      metrics.each do |metric|
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/#{metric}?range=#{option(:stats_range)}")))
        stats.each { |stat| report("#{metric}_#{stat}".to_sym => response['couchdb'][metric].ergo[stat] || 0) }
      end
    else
      now = Time.now.to_i
      seconds_since_last_run = now - (memory(:last_run_time) || 0)
      remember(:last_run_time, now)

      metrics.each do |metric|
        key = "#{metric}_sum".to_sym
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/#{metric}")))
        count = response['couchdb'][metric].ergo['current'] || 0
        value = count - (memory(key) || 0)
        report(key => value)
        remember(key, count)

        key = "#{metric}_mean".to_sym
        report(key => value/seconds_since_last_run.to_f)
      end
    end
  end
end
