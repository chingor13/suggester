module Suggester
  module Handlers
  end
end

list = Dir.glob(File.expand_path(File.dirname(__FILE__) + "/handlers/*.rb")).sort
list.each do |f|
  require f
end
