require 'main'
require 'ostruct'

disable :logging unless defined?(Thin)
run Sinatra::Application
