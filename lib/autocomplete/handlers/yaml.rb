require File.expand_path(File.dirname(__FILE__) + '/base')

module Autocomplete
  module Handlers
    class Yaml < Base
      def initialize(params = {})
        @file = params.delete(:file) || raise("must specify a file")
        super(params)
      end

    protected

      def build_cache()
        io = open(@file)
        cache = YAML::load(io.read)
        cache.sort{|x,y| x[:search_term] <=> y[:search_term]}
      end
    end
  end
end


