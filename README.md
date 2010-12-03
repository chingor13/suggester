Suggester
=========

Suggester is an extensible, cache-based auto-suggest server and client for ruby. 
Suggester also supports replication and scheduled refreshing.

To use, you provide a configuration ruby file which registers "handlers".  Handlers
can be any Ruby object that responds to `find`, `match`, and `refresh`.  We've included
3 basic handlers which are easily extensible:

1. Suggester::Handlers::ActiveRecord - pulls all records using an ActiveRecord class
2. Suggester::Handlers::Marshal - deserializes a Marshaled blob from a file or url
3. Suggester::Handlers::Yaml - deserializes YAML from a file or url 

All 3 of these supplied handlers stores in a sorted array of data.  We do a binary 
search to find results.

Documentation & Requirements
----------------------------

Suggester requires the following gems:

* Sinatra
* Vegas
* JSON

Server
------

### Examples

Basic usage:

    suggest_server <config_file.rb>

Config file example (config_file.rb):

    # assuming that Book is an ActiveRecord class
    Suggester::Server.add_handler("books", Suggester::Handlers::ActiveRecord.new(:class => Book))

    # using the Marshal handler
    Suggester::Server.add_handler("cars", Suggester::Handlers::Marshal(:file => "/path/to/file.marshal")

    # using the Yaml handler
    Suggester::Server.add_handler("dogs", Suggester::Handlers::Yaml(:file => "/path/to/file.yml")

### Web Interface

### Creating Custom Handlers

All Handler classes must respond to 2 public instance methods:

    1. find(name, options = {})
    2. match(name, options = {})

These methods should return an array of data that matches the supplied name (search term).

### Refreshing Handlers

Upon server start, we spawn a thread that refreshes handler caches.  We do this to prevent blocking
the webserver which a cache reloads.  Since suggester server should never modify its data source,
we shouldn't have to worry much about concurrency.  Note that results returned may represent an older
state of the cache, but never an in-between cache state.

There are 2 ways to refresh a handler.

The first way is to make a GET request to `/<handler_name>/refresh`.  This call forces the server
to reload the specified cache as soon as possible.

The second way is to schedule recurring refreshes.  When using any handler that inherits from
Suggester::Handlers::Base, you may supply a `:refresh_interval` option (in minutes).  The
server will automatically refresh that cache every `:refresh_interval` minutes.

### Replication

An easy way to set up replication is through configuration and the Marshal or Yaml handlers are
best for the job.  Because the Marshal and Yaml handlers can load from a local file or a url,
you can point the replicant handler to a master server's dump output.

Example Master Configuration:

    Suggester::Server.add_handler("books", Suggester::Handler::ActiveRecord.new(:class => Book))
    Suggester::Server.add_handler("authors", Suggester::Handler::ActiveRecord.new(:class => Book, :name_field => :author))

Replicant Configuration:

    Suggester::Server.add_handler("books", Suggester::Handler::Marshal(:file => "http://<master:port>/books/dump.marshal"))
    Suggester::Server.add_handler("authors", Suggester::Handler::Yaml(:file => "http://<master:port>/books/dump.yml"))

Note that this method of replication uses the pull model -- the replicant must determine when to 
pull from the master.

Client
------

### Examples

Basic usage:

    require 'rubygems'
    require 'suggester'
    require 'suggester/client'

    # create an instance of the client pointing to a server at localhost:5050
    client = Suggester::Client.new(:host => 'localhost', :port => 5050)

    # find begins-with matches
    client.find("books", "A Tale of Two")
    => [{:id => 1, :display_name => "A Tale of Two Cities"}]
    client.find("books", "The ")
    => [{:id => 4, :display_name => "The Origin of Species"},
        {:id => 5, :display_name => "The Catcher in the Rye"},
        {:id => 6, :display_name => "The Lord of the Rings"}]
    client.find("books", "Non-existent")
    => []

    # find exact matches
    client.match("books", "a tale of two cities")
    => [{:id => 1, :display_name => "A Tale of Two Cities"}]
    client.match("books", "A Tale of Two")
    => []
    client.match("books", "The")
    => []

    # tell the server to refresh its handler
    client.refresh("books")
    => true
