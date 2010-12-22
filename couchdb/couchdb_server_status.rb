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
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd/requests?range=#{option(:stats_range)}")))
      stats.each { |stat| report("requests_#{stat}".to_sym => response['httpd']['requests'].ergo[stat]) }

      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/request_time?range=#{option(:stats_range)}")))
      stats.each { |stat| report("request_time_#{stat}".to_sym => response['couchdb']['request_time'][stat]) }
    else
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd/requests")))
      requests_count = response['httpd']['requests'].ergo['count'] || 0
      report(:requests_sum => requests_count - (memory(:requests_sum) || 0))
      remember(:requests_sum, requests_count)
    end
  end

end
