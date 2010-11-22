require 'rubygems'
require 'sinatra/base'
require 'array_bsearch'
require 'yaml'
require 'json'
require 'pp'

module Autocomplete
  class Server < Sinatra::Base

    def initialize(*args)
      super(*args)
      Thread.new do
        loop do
          sleep(10)
          self.class.handlers.each do |name, handler|
            if handler.needs_refresh?
puts "refreshing #{name}"
              handler.refresh!
            end
          end
        end
      end
    end

    # list all handlers currently registered
    get "/" do
      output = "<html><body><h1>Autocomplete Handlers</h1>"
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

    get "/:handler/refresh" do
      handler = params.delete("handler")

      if current_handler = self.class.handler(handler)
        current_handler.force_refresh!
        "OK"
      else
        "FAIL"
      end
    end

    def self.handlers
      @handlers
    end

    def self.handler(name)
      @handlers ||= {}
      @handlers[name]
    end

    def self.add_handler(name, handler)
      @handlers ||= {}
      @handlers[name] = handler
    end

  end
end

