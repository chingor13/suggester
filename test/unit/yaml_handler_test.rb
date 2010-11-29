require File.join(File.dirname(__FILE__), "../test_helper.rb")

class YamlHandlerTest < ActiveSupport::TestCase

  should "raise exception if no file given" do
    assert_raises RuntimeError do
      handler = Autocomplete::Handlers::Yaml.new
    end
  end

  should "load basic yaml file" do
    assert_nothing_raised do
      handler = Autocomplete::Handlers::Yaml.new(:file => yaml_fixture_path)
    end
  end

protected

  def yaml_fixture_path
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'test_yml.yml'))
  end

end
