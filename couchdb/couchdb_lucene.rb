class CouchDBLucenePlugin < Scout::Plugin

  OPTIONS = <<-EOS
    couchdb_port:
      label: The port that CouchDB is running on
      default: 5984
    couchdb_host:
      label: The host that CouchDB is running on
      default: http://127.0.0.1
    database_name:
      label: The name of the database containing the lucene index
    index_name:
      label: The name of the design document and the view of the lucene index. ("search/index" for example)
  EOS

  needs 'net/http', 'json'

  def build_report
    base_url = "#{option(:couchdb_host)}:#{option(:couchdb_port)}/"

    response = JSON.parse(Net::HTTP.get(URI.parse("#{base_url}#{option(:database_name)}/_fti/_design/#{option(:index_name)}")))
    report(:disk_size => b_to_mb(response['disk_size']) || 0)
    report(:doc_count => response['doc_count'] || 0)
    report(:doc_del_count => response['doc_del_count'] || 0)
  end

  def b_to_mb(bytes)
    bytes && bytes.to_f / 1024 / 1024
  end
end
