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
        build_cache()
      end

      # return an array of entry data (sorted)
      def match(params)
        query = params[:query].downcase
        limit = params[:limit]
        limit = limit.to_i unless limit.nil?
        results = find_exact_matches(query, limit)
      end

      # return an array of entry data (sorted)
      def find(params)
        query = params[:query].downcase
        limit = params[:limit]
        limit = limit.to_i unless limit.nil?
        results = find_begin_matches(query, limit)
      end

      protected

      def all_records
        @klass.find(:all, :conditions => @conditions)
      end

      def build_cache
        @cache 
        records.each do |entry|
          @cache << build_entry(entry)
        end
        @cache.sort{|x,y| x[:search_term] <=> y[:search_term]}
      end

      def build_entry(record)
        {
          :search_term => normalize(search_term(record).downcase),
          :data => entry_data(record)
        }
      end

      def search_term(record)
        record.send(@name_field)
      end

      def entry_data(record)
        {
          :key  =>  key(record),
          :name =>  record.send(@name_field)
        }
      end

      def key(record)
        record.send(@id_field)
      end

    end
  end
end
