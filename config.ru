require 'main'
require 'ostruct'

# map '/admin/' do
#   Geido = OpenStruct.new(
#     :theme => "admin"
#   )
# end

disable :logging unless defined?(Thin)
run Sinatra::Application
