require 'ostruct'

Geido = OpenStruct.new(
  :admin_password => 'test',
  :admin_cookie_key => 'geido',
  :admin_cookie_value => '322f42504b3a47536a7c48337a2b2a234f3c21295c746b4643576c4726',
  :theme => ENV["THEME"] || 'default'
)