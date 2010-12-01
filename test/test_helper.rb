ENV["RAILS_ENV"] = "test"

# add to the load path (done by loading gems for you, just not in test)
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

# require the suggester files
require 'suggester'
require 'bundler'
Bundler.setup
require 'active_support'
require 'active_support/test_case'
require 'shoulda'
require 'mocha'

# run the mysql tests if you have set up your mysql.yml
config_file = File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')
RUN_AR_TESTS = File.exists?(config_file)
if RUN_AR_TESTS
  require 'activerecord'
  require 'mysql'
  database_config = YAML::load_file(config_file)["test"]
  ActiveRecord::Base.establish_connection(database_config)
else
  raise "set up your config/database.yml"
end
