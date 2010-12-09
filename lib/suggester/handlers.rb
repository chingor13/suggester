# Defines the module for the basic handle namespace
#
# Author::      Jeff Ching
# Copyright::   Copyright (c) 2010
# License::     Distributes under the same terms as Ruby
module Suggester
  module Handlers
  end
end

# require all the provided base handlers
list = Dir.glob(File.expand_path(File.dirname(__FILE__) + "/handlers/*.rb")).sort
list.each do |f|
  require f
end
