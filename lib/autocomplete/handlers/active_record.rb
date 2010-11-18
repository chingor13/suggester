require File.expand_path(File.dirname(__FILE__) + '/base')

module Autocomplete
  module Handlers
    class ActiveRecord < Base

      def initialize(klass, id_field, name_field, conditions = {})
        @klass = klass
        @id_field = id_field
        @name_field = name_field
        @conditions = conditions
        build_cache()
      end

      def match(params)
        query = params[:query].downcase
        results = find_exact_matches(query)
        results.values.sort{|x,y| x[:name] <=> y[:name]}
      end

      def find(params)
        query = params[:query].downcase
        results = find_begin_matches(query)
#query2 = removals(query)
#results.merge!(find_begin_matches(query2))
        results.values.sort{|x,y| x[:name] <=> y[:name]}
      end

      protected

      def all_records
        @klass.find(:all, :conditions => @conditions)
      end

      def build_cache
        @cache ||= begin
          cache = []
          all_records.each do |entry|
            cache << build_entry(entry)
          end
          cache.sort{|x,y| x[:search_term] <=> y[:search_term]}
        end
      end

      def build_entry(record)
        {
          :search_term => search_term(record).downcase,
          :data => entry_data(record)
        }
      end

      def search_term(record)
        record.send(:name)
      end

      def entry_data(record)
        {
          :key  =>  record.send(:id),
          :name =>  record.send(:name)
        }
      end

    end
  end
end
