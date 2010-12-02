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

Documentation & Requirements
----------------------------

Suggester requires the following gems:

* Sinatra
* JSON

Examples
--------

Basic usage:

    suggest_server <config_file.rb>

Config file example (config_file.rb):

    # assuming that Book is an ActiveRecord class
    Suggester::Server.add_handler("books", Suggester::Handlers::ActiveRecord.new(:class => Book))

    # using the Marshal handler
    Suggester::Server.add_handler("cars", Suggester::Handlers::Marshal(:file => "/path/to/file.marshal")

    # using the Yaml handler
    Suggester::Server.add_handler("dogs", Suggester::Handlers::Yaml(:file => "/path/to/file.yml")

Creating Custom Handlers
------------------------

All Handler classes must respond to 2 public instance methods:

    1. find(name, options = {})
    2. match(name, options = {})

