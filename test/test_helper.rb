ENV["RAILS_ENV"] = "test"

# add to the load path (done by loading gems for you, just not in test)
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

# require the autocomplete files
require 'autocomplete'
require 'active_support'
require 'active_support/test_case'
require 'shoulda'
require 'mocha'
