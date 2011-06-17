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
    ACCEPTED_FORMATS = ['yml', 'json', 'html']

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
        invalid_format
      end
    end

    # find exact matches for the query string
    get "/:handler/match/*" do
      handler = params.delete("handler")
      format, params[:query] = parse_format_and_query_from_splat(params)
      matches = self.class.handler(handler).match(params)
      case(format)
      when 'yml'
        matches.to_yaml
      when 'json'
        matches.to_json
      when 'html'
        output = "<html><body>"
        output << matches.map{|r| r.inspect}.join('<br/>')
        output << "</body></html>"
      else
        invalid_format
      end
    end

    # find matches that begin with the query string
    get "/:handler/find/*" do
      handler = params.delete("handler")
      format, params[:query] = parse_format_and_query_from_splat(params)
      matches = self.class.handler(handler).find(params)
      case(format)
      when 'yml'
        matches.to_yaml
      when 'json'
        matches.to_json
      when 'html'
        output = "<html><body>"
        output << matches.map{|r| r.inspect}.join('<br/>')
        output << "</body></html>"
      else
        invalid_format
      end
    end

    # force a refresh of the specified handler
    get "/:handler/refresh.:format" do
      format = params.delete("format")
      handler = params.delete("handler")

      if current_handler = self.class.handler(handler)
        current_handler.force_refresh!
        response = {"return" => "OK"}
      else
        response = {"return" => "FAIL"}
      end

      case(format)
      when 'yml'
        response.to_yaml
      when 'json'
        response.to_json
      when 'html'
        output = "<html><body>"
        output << response.map{|r| r.inspect}.join('<br/>')
        output << "</body></html>"
      else
        invalid_format
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

    def parse_format_and_query_from_splat(params)
      # get the splat param(s) - Array of arrays.
      splat = params.delete("splat")
      return nil, nil unless splat.kind_of?(Array)
      
      # were only expecting one splat, get the first one and split it on period
      splat = splat.first.split(".")
      
      # format is the last token
      format = splat.pop
      
      # If format isn't acceptable, push it back onto splat and set format to nil
      unless ACCEPTED_FORMATS.include?(format)
        splat.push(format) 
        format = nil
      end
      # join the array of of splat as query
      query = splat.join(".")
 
      # return format and query
      return format, query
    end

    def invalid_format(message = "Invalid Format")
      [ 404, {'Content-Type' => 'text/plain'},  message ]
    end

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

