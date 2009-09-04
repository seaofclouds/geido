require 'main'

disable :logging unless defined?(Thin)
run Sinatra::Application
