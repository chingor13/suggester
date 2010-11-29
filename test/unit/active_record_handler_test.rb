require File.join(File.dirname(__FILE__), "../test_helper.rb")

class ActiveRecordHandlerTest < ActiveSupport::TestCase
  if RUN_AR_TESTS
    class Book < ActiveRecord::Base
    end

    should "raise exception if no class given" do
      assert_raises RuntimeError do
        handler = Autocomplete::Handlers::ActiveRecord.new()
      end
    end

    should "load basic active_record handler" do
      assert_nothing_raised do
        handler = Autocomplete::Handlers::ActiveRecord.new( :class => Book, 
                                                            :id_field => :id, 
                                                            :name_field => :title)
        assert_equal(6, handler.cache.length)
      end
    end

    should "load a sorted cache" do
      handler = Autocomplete::Handlers::ActiveRecord.new( :class => Book, 
                                                          :id_field => :id, 
                                                          :name_field => :title)
      search_strings = handler.cache.map{|entry| entry[:search_term]}
      sorted_search_strings = search_strings.sort
      assert_equal(sorted_search_strings, search_strings)
    end

    should "find begins with matches" do
      handler = Autocomplete::Handlers::ActiveRecord.new( :class => Book, 
                                                          :id_field => :id, 
                                                          :name_field => :title)
      matches = handler.find(:query => "the")
      assert_equal(3, matches.length)

      matches = handler.find(:query => "a ")
      assert_equal(1, matches.length)
    end

    should "find exact matches" do
      handler = Autocomplete::Handlers::ActiveRecord.new( :class => Book, 
                                                          :id_field => :id, 
                                                          :name_field => :title)
      matches = handler.match(:query => "the")
      assert_equal(0, matches.length)

      matches = handler.match(:query => "the catcher in the rye")
      assert_equal(1, matches.length)
    end

    should "normalize search string" do
      handler = Autocomplete::Handlers::ActiveRecord.new( :class => Book, 
                                                          :id_field => :id, 
                                                          :name_field => :title)
      matches = handler.find(:query => "THE")
      assert_equal(3, matches.length)

      matches = handler.match(:query => "THE cAtChEr In ThE rYe")
      assert_equal(1, matches.length)
    end

  end


protected

  def yaml_file
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'yaml.yml'))
  end

end
