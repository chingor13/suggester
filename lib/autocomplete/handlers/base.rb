module Autocomplete
  module Handlers
    class Base
      attr_reader :cache

      def initialize(params = {})
        @removals       = params[:removals] || []
        @substitutions  = params[:substitutions] || {}
        @ignore_keys    = (params[:ignore_keys] || []).index_by{|r| r}

        # NOTE: This @cache MUST be sorted by it's key value
        @cache = []
      end

      def match(params)
        raise "abstract"
      end

      def find(params)
        raise "abstract"
      end

    protected

      def normalize(string)
        removals(substitutions(string))
      end

      def removals(string)
        result = string.dup
        @removals.each do |regex|
          result.gsub!(Regexp.new(regex), "")
        end
        result
      end

      def substitutions(string)
        result = string.dup
        @substitutions.each do |regex, replace|
          result.gsub!(Regexp.new(regex), replace)
        end
        # always strip extra spaces
        result.gsub!(/\s+/, ' ')
        result.strip!
        result
      end

      def key(record)
        raise "must define how to get a key from a record?"
      end

      def all_records
        []
      end

      # return all records except those with a key value in the @ignore_keys list
      def records
        all_records.reject{|r| @ignore_keys.has_key?(key(r))}
      end

      # do a binary search through the cache to find the lowest index
      def find_lower_bound(string)
        @cache.bsearch_lower_boundary {|x| x[:search_term] <=> string}
      end

      # returns an array of begins with matches as:
      #   [
      #     {
      #       :key => <key_val>
      #       ...other data
      #     }
      #   ]
      def find_begin_matches(query, limit)
        keys = {}
        results = []

        [query, substitutions(query), removals(query)].uniq.each do |search_string|
          lower_bound = find_lower_bound(search_string)
          for i in lower_bound..@cache.length
            # stop looking if we are no longer matching OR we have found enough matches
            break if @cache[i][:search_term].index(search_string) != 0 || (limit && results.length >= limit)

            # don't add duplicate keys to the results
            key = @cache[i][:data][:key]
            next if keys[key]

            # add to the results and note that we have saved this key value
            results << @cache[i]
            keys[@cache[i][:data][:key]] = true
          end
          break if limit && results.length >= limit
        end

        # limit the results (default to empty result)
        results = results[0,limit] || [] if limit
        results.sort!{|x,y| x[:search_term] <=> y[:search_term]}
        results.map{|r| r[:data]}
      end

      # returns an array of exact matches as:
      #   [ 
      #     {
      #       :key => <key_val>
      #       ...other data
      #     }
      #   ]
      def find_exact_matches(query, limit)
        keys = {}
        results = []

        # try the exact search input, then try with substitutions and then try with removals
        [query, substitutions(query), removals(query)].uniq.each do |search_string|
          lower_bound = find_lower_bound(search_string)
          for i in lower_bound..@cache.length
            # stop looking if we are no longer matching OR we have found enough matches
            break if @cache[i][:search_term] != search_string || (limit && results.length >= limit)

            # don't add duplicate keys to the results
            key = @cache[i][:data][:key]
            next if keys[key]

            # add to the results and note that we have saved this key value
            results << @cache[i]
            keys[@cache[i][:data][:key]] = true
          end
          break if limit && results.length >= limit
        end

        # limit the results (default to empty result)
        results = results[0,limit] || [] if limit
        results.sort!{|x,y| x[:search_term] <=> y[:search_term]}
        results.map{|r| r[:data]}
      end

    end
  end
end
