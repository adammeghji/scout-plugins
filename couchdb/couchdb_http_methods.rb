class CouchDBHttpMethodsPlugin < Scout::Plugin

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

    http_methods = %w{GET POST PUT DELETE HEAD}
    if version.to_f >= 0.11
      stats = %w{count mean max stddev}
      http_methods.each do |http_method|
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd_request_methods/#{http_method}?range=#{option(:stats_range)}")))
        stats.each { |stat| report("httpd_request_methods_#{http_method}_#{stat}".to_sym => response['httpd_request_methods'][http_method].ergo[stat] || 0) }
      end
    else
      http_methods.each do |http_method|
        key = "requests_count_#{http_method}".to_sym
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd_request_methods/#{http_method}")))
        count = response['httpd_request_methods'][http_method].ergo['count'] || 0
        report(key => count - (memory(key) || 0))
        remember(key, count)
      end
    end
  end

end
