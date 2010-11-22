require 'rubygems'
require 'sinatra/base'
require 'array_bsearch'
require 'yaml'
require 'json'
require 'pp'

module Autocomplete
  class Server < Sinatra::Base

    DEFAULT_REFRESH_RATE = 20

    attr_accessor :handlers_to_refresh

    def initialize(*args)
      @handlers_to_refresh = []
      super(*args)
      Thread.new do
        while(true) do
          puts "running thread"
          pp self
          sleep(self.class.refresh_rate)
          puts "after sleep"
          while(handler_name = @handlers_to_refresh.shift) do

          end
        end
      end
    end

    # list all handlers currently registered
    get "/" do
      output = "<html><body><h1>Autocomplete Handlers</h1>"
      output << self.class.handlers.keys.sort.map{|n| "<a href='/#{n}/dump'>#{n} (#{self.class.handler(n).cache.size})</a>"}.join('<br/>')
      output << "</body></html>"
    end

    # dump out the contents of the handler's cache
    get "/:handler/dump" do
      handler = params.delete("handler")
      output = "<html><body>"
      output << self.class.handler(handler).cache.map{|r| r.inspect}.join('<br/>')
      output << "</body></html>"
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
        self.class.add_handler(handler, current_handler.class.new(current_handler.definition))
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

    def self.refresh_rate
      @refresh_rate ||= DEFAULT_REFRESH_RATE
    end

    def self.set_refresh_rate(refresh_rate)
pp "setting refresh_rate: #{refresh_rate}"
      @refresh_rate = refresh_rate
      # convert to seconds from minutes
      @refresh_rate = (@refresh_rate.to_f * 60).to_i unless @refresh_rate.nil?
    end

    def self.add_config(handler_name, handler_class, handler_params)
      @handler_config ||= {}
      @handler_config[handler_name] = {
        :class  =>  handler_class,
        :params =>  handler_params,
      }
    end
  end
end

