ENV["RAILS_ENV"] = "test"

# add to the load path (done by loading gems for you, just not in test)
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

# require the autocomplete files
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "autocomplete.rb"))
require 'active_support'
require 'shoulda'
