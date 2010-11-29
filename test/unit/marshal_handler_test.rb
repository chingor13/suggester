require File.expand_path(File.join(File.dirname(__FILE__), "../test_helper.rb"))

class MarshalHandlerTest < ActiveSupport::TestCase

  should "raise exception if no file given" do
    assert_raises RuntimeError do
      handler = Autocomplete::Handlers::Marshal.new
    end
  end

  should "load basic marshal file" do
    assert_nothing_raised do
      handler = Autocomplete::Handlers::Marshal.new(:file => marshal_file)
      assert_equal(6, handler.cache.length)
    end
  end

  should "load a sorted cache" do
    handler = Autocomplete::Handlers::Marshal.new(:file => marshal_file)
    search_strings = handler.cache.map{|entry| entry[:search_term]}
    sorted_search_strings = search_strings.sort
    assert_equal(sorted_search_strings, search_strings)
  end

  should "load marshal from uri" do
    # stub the open uri
    OpenURI.stubs(:open_uri).returns(File.open(marshal_file))
    url = "http://autocomplete.server.com/handler/dump.marshal"
    assert_nothing_raised do
      handler = Autocomplete::Handlers::Marshal.new(:file => url)
      assert_equal(6, handler.cache.length)
    end
  end

  should "find begins with matches" do
    handler = Autocomplete::Handlers::Marshal.new(:file => marshal_file)
    matches = handler.find(:query => "a")
    assert_equal(3, matches.length)

    matches = handler.find(:query => "aa")
    assert_equal(2, matches.length)
  end

  should "find exact matches" do
    handler = Autocomplete::Handlers::Marshal.new(:file => marshal_file)
    matches = handler.match(:query => "aar")
    assert_equal(0, matches.length)

    matches = handler.match(:query => "aardvark")
    assert_equal(1, matches.length)
  end

  should "normalize search string" do
    handler = Autocomplete::Handlers::Marshal.new(:file => marshal_file)
    matches = handler.match(:query => "AARDVARK")
    assert_equal(1, matches.length)
  end

protected

  def marshal_file
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'marshal.marshal'))
  end

end
