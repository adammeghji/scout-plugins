class CouchDBHttpResponsesPlugin < Scout::Plugin

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

    http_status_codes = %w{200 201 202 301 304 400 401 403 404 405 409 412 500}
    if version.to_f >= 0.11
      http_status_codes.each do |status_code|
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd_status_codes/#{status_code}?range=#{option(:stats_range)}")))
        report("httpd_status_codes_#{status_code}_count".to_sym => response['httpd_status_codes'][status_code].ergo['sum'] || 0)
      end
    else
      http_status_codes.each do |status_code|
        key = "httpd_status_codes_#{status_code}_count".to_sym
        response = JSON.parse(Net::HTTP.get(URI.parse(base_url + "_stats/httpd_status_codes/#{status_code}")))
        count = response['httpd_status_codes'][status_code].ergo['count'] || 0
        report(key => count - (memory(key) || 0))
        remember(key, count)
      end
    end
  end
end

