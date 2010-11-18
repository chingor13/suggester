module Autocomplete
  module Handlers
    class Base
      attr_reader :cache

      def initialize(*attrs)
        @cache = []
      end

      def match(params)
        raise "abstract"
      end

      def find(params)
        raise "abstract"
      end

    protected

      def all_records
        []
      end

      def find_lower_bound(string)
        @cache.bsearch_lower_boundary {|x| x[:search_term] <=> string}
      end

      def find_begin_matches(query)
        lower_bound = find_lower_bound(query)
        results = []
        for i in lower_bound..@cache.length
          break if @cache[i][:search_term].index(query) != 0
          results << @cache[i][:data]
        end
        results.index_by{|result|result[:key]}
      end

      # returns a hash of matched values as:
      #   { 
      #     :key  => {
      #       :search_term => [search_term],
      #       :data        => {
      #         :key => X
      #         ...other data
      #       },
      #     }
      #   }
      def find_exact_matches(query)
        lower_bound = find_lower_bound(query)
        results = []
        for i in lower_bound..@cache.length
          break if @cache[i][:search_term] != query
          results << @cache[i][:data]
        end
        results.index_by{|result|result[:key]}
      end

    end
  end
end
