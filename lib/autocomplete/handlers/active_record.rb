require File.expand_path(File.dirname(__FILE__) + '/base')

module Autocomplete
  module Handlers
    class ActiveRecord < Base

      def initialize(params = {})
        @klass      = params[:class]      || raise("must specify a class")
        @klass = @klass.constantize if @klass.is_a?(String)
        @id_field   = params[:id_field]   || :id
        @name_field = params[:name_field] || :name
        @conditions = params[:conditions] || {}
        super(params)
      end

      protected

      def all_records
        @klass.find(:all, :conditions => @conditions)
      end

      def build_cache
        cache = []
        all_records.each do |entry|
          cache << build_entry(entry)
        end
        cache.sort{|x,y| x[:search_term] <=> y[:search_term]}
      end

      def build_entry(record)
        {
          :search_term => search_term(record),
          :data => entry_data(record)
        }
      end

      def search_term(record)
        record.send(@name_field).downcase
      end

      def entry_data(record)
        {
          @unique_field_name  =>  record.send(@name_field),
          :id                 =>  record.send(@id_field),
        }
      end

    end
  end
end
