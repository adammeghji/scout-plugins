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
    base_url = "#{option(:couchdb_host)}:#{option(:couchdb_port)}/"

    response = JSON.parse(Net::HTTP.get(URI.parse(base_url)))
    report(:version => response['version'])

    stats = %w{count mean max stddev}
    response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd/requests?range=60")))
    stats.each { |stat| report("requests_#{stat}".to_sym => response['httpd']['requests'].ergo[stat]) }

    response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/couchdb/request_time?range=60")))
    stats.each { |stat| report("request_time_#{stat}".to_sym => response['couchdb']['request_time'][stat]) }
  end

end
