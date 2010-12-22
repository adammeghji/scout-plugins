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

    if version.to_f >= 0.11
      stats = %w{sum mean max stddev}

      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/request_time?range=#{option(:stats_range)}")))
      stats.each { |stat| report("request_time_#{stat}".to_sym => response['couchdb']['request_time'][stat]) }

      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/database_reads?range=#{option(:stats_range)}")))
      stats.each { |stat| report("database_reads_#{stat}".to_sym => response['couchdb']['database_reads'].ergo[stat] || 0) }

      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/database_writes?range=#{option(:stats_range)}")))
      stats.each { |stat| report("database_writes_#{stat}".to_sym => response['couchdb']['database_writes'].ergo[stat] || 0) }
    else
      key = "database_reads_sum".to_sym
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/database_reads")))
      count = response['couchdb']['database_reads'].ergo['current'] || 0
      report(key => count - (memory(key) || 0))
      remember(key, count)

      key = "database_writes_sum".to_sym
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/database_writes")))
      count = response['couchdb']['database_writes'].ergo['current'] || 0
      report(key => count - (memory(key) || 0))
      remember(key, count)
    end
  end
end
