module Autocomplete
  class ClientMock
    def initialize(options = {})
      @mocks = {}
    end

    def match(handler, query, opts = {})
      get_test_response_results("match", handler, query, opts)
    end

    def find(handler, query, opts = {})
      get_test_response_results("find", handler, query, opts)
    end

    def refresh
      true
    end

    def set_test_results(data, type, handler, query, opts = {})
      opts[:query] = query
      key = "#{type}--#{handler}"
      @mocks[key] ||= []
      @mocks[key] << {:opts => opts, :buffer => data}
    end

    def clear_test_results
      @mocks = {}
    end

    private

    def get_test_response_results(type, handler, query, opts)
      key = "#{type}--#{handler}"
      match = @mocks[key].and.detect do |m|
        options_match?(m[:opts], opts)
      end
      match.and[:buffer] || []
    end

    def options_match?(opts1, opts2)
      opts1.each do |k,v|
        unless opts2.keys.include?(k)
          return false
        end
        unless opts2[k] == v
          return false
        end
      end
      true
    end

  end
end
