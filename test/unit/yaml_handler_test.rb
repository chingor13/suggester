require File.expand_path(File.join(File.dirname(__FILE__), "../test_helper.rb"))

class YamlHandlerTest < ActiveSupport::TestCase

  should "raise exception if no file given" do
    assert_raises RuntimeError do
      handler = Suggester::Handlers::Yaml.new
    end
  end

  should "load basic yaml file" do
    assert_nothing_raised do
      handler = Suggester::Handlers::Yaml.new(:file => yaml_file)
      assert_equal(6, handler.cache.length)
    end
  end

  should "load a sorted cache" do
    handler = Suggester::Handlers::Yaml.new(:file => yaml_file)
    search_strings = handler.cache.map{|entry| entry[:search_term]}
    sorted_search_strings = search_strings.sort
    assert_equal(sorted_search_strings, search_strings)
  end

  should "load yaml from uri" do
    # stub the open uri
    OpenURI.stubs(:open_uri).returns(File.open(yaml_file))
    url = "http://suggester.server.com/handler/dump.yml"
    assert_nothing_raised do
      handler = Suggester::Handlers::Yaml.new(:file => url)
      assert_equal(6, handler.cache.length)
    end
  end

  should "find begins with matches" do
    handler = Suggester::Handlers::Yaml.new(:file => yaml_file)
    matches = handler.find(:query => "a")
    assert_equal(3, matches.length)

    matches = handler.find(:query => "aa")
    assert_equal(2, matches.length)
  end

  should "find exact matches" do
    handler = Suggester::Handlers::Yaml.new(:file => yaml_file)
    matches = handler.match(:query => "aar")
    assert_equal(0, matches.length)

    matches = handler.match(:query => "aardvark")
    assert_equal(1, matches.length)
  end

  should "normalize search string" do
    handler = Suggester::Handlers::Yaml.new(:file => yaml_file)
    matches = handler.match(:query => "AARDVARK")
    assert_equal(1, matches.length)
  end


protected

  def yaml_file
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'yaml.yml'))
  end

end
