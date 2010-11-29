require 'autocomplete/handlers/helpers/refresh'

module Autocomplete
  module Handlers
    class Base
      # name of the field in the data hash that should be unique
      attr_accessor :unique_field_name

      include Autocomplete::Handlers::Helpers::Refresh
      def initialize(params = {})
        @unique_field_name = params[:unique_field_name] || :display_string
        @refresh_interval = params.delete(:refresh_interval)
        @last_refreshed_at = Time.now
        @cache = build_cache
      end

      # Returns an array of hashes with the following format:
      #   [
      #     :search_term    =>  <string>,
      #     :data           =>  {
      #       <unique_field_name> =>  <anything>
      #       ...other data to be returned
      #     }
      #   ]
      # NOTE: must be sorted by :search_term
      def cache
        @cache
      end

      # Returns an array of data hashes that are an exact match for params[:query]
      def match(params)
        query = params[:query].downcase
        limit = params[:limit]
        limit = limit.to_i unless limit.nil?
        results = find_exact_matches(query, limit)
      end

      # Returns an array of data hashes that begin with params[:query]
      def find(params)
        query = params[:query].downcase
        limit = params[:limit]
        limit = limit.to_i unless limit.nil?
        results = find_begin_matches(query, limit)
      end

    protected

      # Build a copy of the cache (needs to be specified by subclasses)
      def build_cache
        []
      end

      # do a binary search through the cache to find the lowest index
      def find_lower_bound(string)
        @cache.bsearch_lower_boundary {|x| x[:search_term] <=> string}
      end

      # returns an array of begins with matches as:
      #   [ 
      #     {
      #       <unique_field_name> => <anything>
      #       ...other data
      #     }
      #   ]
      def find_begin_matches(search_string, limit)
        results = []
        lower_bound = find_lower_bound(search_string)

        for i in lower_bound...@cache.length
          # stop looking if we are no longer matching OR we have found enough matches
          break if @cache[i][:search_term].index(search_string) != 0 || (limit && results.length >= limit)
          results << @cache[i]
        end

        results.map{|r| r[:data]}
      end

      # returns an array of exact matches as:
      #   [ 
      #     {
      #       <unique_field_name> => <anything>
      #       ...other data
      #     }
      #   ]
      def find_exact_matches(search_string, limit)
        results = []
        lower_bound = find_lower_bound(search_string)

        for i in lower_bound...@cache.length
          # stop looking if we are no longer matching OR we have found enough matches
          break if @cache[i][:search_term] != search_string || (limit && results.length >= limit)
          results << @cache[i]
        end

        results.map{|r| r[:data]}
      end

    end
  end
end
