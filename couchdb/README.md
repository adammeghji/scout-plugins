# CouchDB Scout Plugins

This directory contains a series of [Scout](http://scoutapp.com) plugins that can be used with [CouchDB](http://couchdb.apache.org/).

## The Plugins

* **CouchDBServerStatusPlugin** - Reports CouchDB version, database reads, writes, and request times
* **CouchDBHttpMethodsPlugin** - Reports stats on GET, POST, PUT, DELETE, and HEAD requests
* **CouchDBHttpResponsesPlugin** - Reports counts of the various HTTP status codes returned by CouchDB
* **CouchDBHttpStatsPlugin** - Reports stats on HTTP requests, bulk requests, view reads, and the number of clients requesting _changes
* **CouchDBDatabasePlugin** - Reports stats on an individual database, including document count, size on disk, and more
* **CouchDBLucenePlugin** - Reports stats on an individual couchdb-lucene index, including document count, size on disk, and more

## Scout Setup
All plugins allow you to specify your CouchDB Host and port in the plugin settings.  A **Status Range** setting is also used for CouchDB versions >= 0.11.
The value of this setting is in seconds (values values are 60, 300, or 900), and should match the Scout report interval you configure for the plugin.

## CouchDB Versions

### CouchDB 0.11 and later
The stats API was improved in 0.11, allowing the plugins to report more details, including mean, max, and standard deviation for most statistics.
 
### CouchDB 0.9 and 0.10
Only counts are supported for the majority of statistics.  That is because there is no reliable way to get the other statistics for a given time interval.

### CouchDB Lucene
The CouchDBLucenePlugin has been tested with version 0.5.6
