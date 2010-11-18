require 'rubygems'
require 'sinatra/base'
require 'array_bsearch'
require 'pp'

module Autocomplete
  class Server < Sinatra::Base

    # list all handlers currently registered
    get "/" do
      output = "<html><body><h1>Autocomplete Handlers</h1>"
      output << self.class.handlers.keys.sort.map{|n| "<a href='/#{n}/dump'>#{n}</a>"}.join('<br/>')
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
      matches.inspect
    end

    # find matches that begin with the query string
    get "/:handler/find/:query.:format" do
      format = params.delete("format")
      handler = params.delete("handler")
      matches = self.class.handler(handler).find(params)
      matches.inspect
    end

    get "/:handler/refresh" do

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

