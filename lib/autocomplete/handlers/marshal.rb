require File.expand_path(File.dirname(__FILE__) + '/base')

module Autocomplete
  module Handlers
    class Marshal < Base

      def initialize(params = {})
        @file = params.delete(:file) || raise("must specify a file")
        super(params)
      end

    protected

      def build_cache()
        ::Marshal.load(open(@file).read)
      end

    end
  end
end
