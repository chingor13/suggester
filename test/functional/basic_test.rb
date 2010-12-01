require File.expand_path(File.join(File.dirname(__FILE__), "../test_helper.rb"))
require 'rack/test'

Suggester::Server.add_handler("yaml_handler", Suggester::Handlers::Yaml.new(:file => File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'yaml.yml'))))
Suggester::Server.add_handler("marshal_handler", Suggester::Handlers::Marshal.new(:file => File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'marshal.marshal'))))

class BasicTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Suggester::Server
  end

  should "list all handlers on index page" do
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('yaml_handler')
    assert last_response.body.include?('marshal_handler')
  end

  should "dump data in yaml format" do
    get '/yaml_handler/dump.yml'
    assert last_response.ok?
    assert_nothing_raised do
      data = YAML::load(last_response.body)
      assert_equal(6, data.length)
    end
  end

  should "dump data in json format" do
    get '/yaml_handler/dump.json'
    assert last_response.ok?
    assert_nothing_raised do
      data = JSON::load(last_response.body)
      assert_equal(6, data.length)
    end
  end

  should "dump data in marshal format" do
    get '/yaml_handler/dump.marshal'
    assert last_response.ok?
    assert_nothing_raised do
      data = Marshal.load(last_response.body)
      assert_equal(6, data.length)
    end
  end

  should "find begins with matches in yaml format" do
    get '/yaml_handler/find/a.yml'
    assert last_response.ok?
    assert_nothing_raised do
      data = YAML::load(last_response.body)
      assert_equal(3, data.length)
    end
  end

  should "find begins with matches in json format" do
    get '/yaml_handler/find/a.json'
    assert last_response.ok?
    assert_nothing_raised do
      data = JSON::load(last_response.body)
      assert_equal(3, data.length)
    end
  end

  should "find with limit" do
    get '/yaml_handler/find/a.yml', :limit => 2
    assert last_response.ok?
    assert_nothing_raised do
      data = YAML::load(last_response.body)
      assert_equal(2, data.length)
    end
  end

  should "refresh" do
    # handler shouldn't need a refresh
    assert !Suggester::Server.handler("yaml_handler").needs_refresh?

    # force the server to refresh when it gets a chance
    get '/yaml_handler/refresh'
    assert last_response.ok?
    assert_equal("OK", last_response.body)

    # should need a refresh
    assert Suggester::Server.handler("yaml_handler").needs_refresh?

    # restore state
    Suggester::Server.handler("yaml_handler").refresh!
    assert !Suggester::Server.handler("yaml_handler").needs_refresh?
  end

  should "fail to refresh non-existent handler" do
    get '/non_existent/refresh'
    assert last_response.ok?
    assert_equal("FAIL", last_response.body)
  end

end
