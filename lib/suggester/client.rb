# This is a simple client to access a Suggester::Server instance.
#
# Author::    Jeff Ching
# Copyright:: Copyright (c) 2010
# License::   Distributes under the same terms as Ruby
require 'open-uri'
require 'cgi'
require 'json'
require 'timeout'

module Suggester
  # Simple client to access a Suggester::Server instance
  class Client
    attr_accessor :host, :port
    attr_accessor :logger

    # server uses sinatra with default port 17500
    DEFAULT_HOST = "localhost"
    DEFAULT_PORT = 17500

    # Create an instance of the client
    def initialize(options = {})
      @host = options[:host] || DEFAULT_HOST
      @port = options[:port] || DEFAULT_PORT
      @logger = options[:logger]
    end

    # Match returns an array of data returned that is an exact match for the query
    # string provided
    #
    # ==== Parameters
    #
    # * <tt>type</tt> - The name of the handler like "book"
    # * <tt>query</tt> - The search term you are matching on
    # * <tt>options</tt> - Hash of optionally parameters which are passed as query
    #   parameters.  Includes the <tt>:limit</tt> option.
    #
    # ==== Examples
    #
    #   # find exact matches
    #   client = Suggester::Client.new
    #   client.match("book", "A Tale of Two Cities")                # returns all books that match "A Tale of Two Cities"
    #   client.match("book", "A Tale of Two Cities", :limit => 1)   # return the first match for "A Tale of Two Cities"
    def match(type, query, options = {})
      fetch_response(build_url(type, "match", query, options))
    end

    # Find returns an array of data returned for records that start with query
    # string provided
    #
    # ==== Parameters
    #
    # * <tt>type</tt> - The name of the handler like "book"
    # * <tt>query</tt> - The search term you are searching on
    # * <tt>options</tt> - Hash of optionally parameters which are passed as query
    #   parameters.  Includes the <tt>:limit</tt> option.
    #
    # ==== Examples
    #
    #   # find exact matches
    #   client = Suggester::Client.new
    #   client.match("book", "A Tale")                # returns all books that match "A Tale of Two Cities"
    #   client.match("book", "A Tale", :limit => 1)   # return the first match for "A Tale of Two Cities"
    def find(type, query, options = {})
      fetch_response(build_url(type, "find", query, options))
    end

    # Refresh tells the server to force a reload of its cached data
    #
    # ==== Parameters
    #
    # * <tt>type</tt> - The name of the handler to refresh
    def refresh(type)
      url = "http://#{@host}:#{@port}/#{type}/refresh.json"
      response = fetch_response(url)
      return response.is_a?(Hash) && response["return"] == "OK"
    end

  private

    def fetch_response(url) #:nodoc:
      response = []
      begin
        Timeout::timeout(0.5) do
          open(url) do |content|
            response = JSON.parse(content.read)
          end
        end
      rescue Timeout::Error => e
        @logger.error("Timeout: #{e}\n#{url}") if @logger
      rescue => e
        @logger.error("Error: #{e}\nURL: #{url}\nStack Trace:\n#{e.backtrace}") if @logger
      end
      response
    end

    def build_url(type, method, query, options) #:nodoc:
      url = "http://#{@host}:#{@port}/#{type}/#{method}/#{CGI::escape(query)}.json"
      unless options.empty?
        s = []
        options.each do |k,v|
          s << "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"
        end
        url = url + "?" + s.join("&")
      end
      url
    end
  end
end
