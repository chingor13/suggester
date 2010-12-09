# This is the core server for the Suggester gem.  It extends the basic sinatra server
# and provides a basic interface to browse and query the server.
#
# The server supports output in HTML, YAML, JSON, and Marshal output
#
# Author::    Jeff Ching
# Copyright:: Copyright(c) 2010
# License::   Distribues under the same terms as Ruby
require 'sinatra/base'
require 'yaml'
require 'json'
require 'open-uri'
require 'array_bsearch'
require File.expand_path(File.join(File.dirname(__FILE__), 'handlers.rb'))

module Suggester
  # Core server class
  class Server < Sinatra::Base

    # Create an instance of the server. At this time, we spawn a separate thread
    # that will reload handlers as needed to prevent locking the server thread.
    def initialize(*args)
      super(*args)
      spawn_refresh_thread!
    end

    # list all handlers currently registered
    get "/" do
      output = "<html><body><h1>Suggester Handlers</h1>"
      output << self.class.handlers.keys.sort.map{|n| "<a href='/#{n}/dump.html'>#{n} (#{self.class.handler(n).cache.size})</a>"}.join('<br/>')
      output << "</body></html>"
    end

    # dump out the contents of the handler's cache
    get "/:handler/dump.:format" do
      format = params.delete("format")
      handler = params.delete("handler")

      data = self.class.handler(handler).cache
      case(format)
      when 'yml'
        data.to_yaml
      when 'json'
        data.to_json
      when 'marshal'
        Marshal.dump(data)
      when 'html'
        output = "<html><body>"
        output << data.map{|r| r.inspect}.join('<br/>')
        output << "</body></html>"
      else
        "BAD FORMAT"
      end
    end

    # find exact matches for the query string
    get "/:handler/match/:query.:format" do
      format = params.delete("format")
      handler = params.delete("handler")
      matches = self.class.handler(handler).match(params)
      case(format)
      when 'yml'
        matches.to_yaml
      when 'json'
        matches.to_json
      else
        matches.inspect
      end
    end

    # find matches that begin with the query string
    get "/:handler/find/:query.:format" do
      format = params.delete("format")
      handler = params.delete("handler")
      matches = self.class.handler(handler).find(params)
      case(format)
      when 'yml'
        matches.to_yaml
      when 'json'
        matches.to_json
      else
        matches.inspect
      end
    end

    # force a refresh of the specified handler
    get "/:handler/refresh" do
      handler = params.delete("handler")

      if current_handler = self.class.handler(handler)
        current_handler.force_refresh!
        "OK"
      else
        "FAIL"
      end
    end

    # Returns the hash of all handler names to their instances
    def self.handlers
      @handlers
    end

    # Returns the handler instance given the handler name
    def self.handler(name)
      @handlers ||= {}
      @handlers[name]
    end

    # Register a handler instance to its handler name
    def self.add_handler(name, handler)
      @handlers ||= {}
      @handlers[name] = handler
    end

    private

    def spawn_refresh_thread! #:nodoc:
      Thread.new do
        loop do
          sleep(10)
          self.class.handlers.each do |name, handler|
            handler.refresh! if handler.needs_refresh?
          end
        end
      end
    end

  end
end

