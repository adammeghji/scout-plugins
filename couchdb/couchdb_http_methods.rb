class CouchDBServerStatusPlugin < Scout::Plugin

  OPTIONS = <<-EOS
    couchdb_port:
      label: The port that CouchDB is running on
      default: 5984
    couchdb_host:
      label: The host that CouchDB is running on
      default: http://127.0.0.1
  EOS

  needs 'net/http', 'json', 'facets'

  def build_report
    base_url = "#{option(:couchdb_host)}:#{option(:couchdb_port)}/_stats/"

    stats = %w{count mean max stddev}
    http_methods = %w{GET POST PUT DELETE HEAD}
    http_methods.each do |http_method|
      response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "httpd_request_methods/#{http_method}?range=60")))
      stats.each { |stat| report("httpd_request_methods_#{http_method}_#{stat}".to_sym => response['httpd_request_methods'][http_method].ergo[stat] || 0) }
    end
  end

end
