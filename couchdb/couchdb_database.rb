class CouchDBHttpStatsPlugin < Scout::Plugin

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
    database_name:
      label: The name of the database you wish to get stats for
  EOS

  needs 'net/http', 'json'

  def build_report
    base_url = "#{option(:couchdb_host)}:#{option(:couchdb_port)}/"

    response = JSON.parse(Net::HTTP.get(URI.parse(base_url + option(:database_name))))
    report(:doc_count => response['doc_count'] || 0)
    report(:doc_del_count => response['doc_del_count'] || 0)
    report(:disk_size => response['disk_size'] || 0)
    report(:purge_seq => response['purge_seq'] || 0)
    report(:update_seq => response['update_seq'] || 0)
  end
end
