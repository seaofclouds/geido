require 'rubygems'
require 'sinatra'
require 'builder'
require 'sinatra/sequel'
require 'ostruct'
require 'redcloth'
require 'haml'
require 'sass'
require 'json'
require 'rack-flash'

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'plugin'
require 'db'
require 'post'
require 'tag'
require 'tagging'

Plugin.load!

use Rack::Session::Cookie
use Rack::Flash

Geido = OpenStruct.new(
  :admin_password => 'test',
  :admin_cookie_key => 'geido',
  :admin_cookie_value => '322f42504b3a47536a7c48337a2b2a234f3c21295c746b4643576c4726',
  :theme => ENV["THEME"] || 'default'
)

set :views,  File.expand_path(File.dirname(__FILE__), "themes/#{Geido.theme}/views")
set :public, File.expand_path(File.dirname(__FILE__), "themes/#{Geido.theme}/public")
PLUGINS_FOLDER = '/../../../plugins' # location of the plugins folder, must be relative to views

custom_theme_routes = "#{File.dirname(__FILE__)}/themes/#{Geido.theme}/routes.rb"
require custom_theme_routes if File.exists?(custom_theme_routes)

helpers do
  def partial(page, options={})
    haml "_#{page}".to_sym, options.merge!(:layout => false)
  end
  
  def admin?
    @admin ||= (request.cookies[Geido.admin_cookie_key] == Geido.admin_cookie_value)
  end

  def auth!
    redirect "/login?jump=#{request.env['REQUEST_URI']}" unless admin?
  end

  def admin
    yield if admin?
  end

  def admin_links(post)
    return unless admin?
    "<form class='admin menu' method='POST' action='/posts/#{post.id}'>
      <a href='/posts/#{post.id}/edit'>Edit</a>
      <input type='hidden' name='_method' value='DELETE' />
      <input type='submit' value='Delete' />
    </form>"
  end

  def date(post)
    "<p class='created_at'>#{post.created_at.strftime('%e %B %Y')}</p>"
  end
  
  def tags(post)
    "<p class='tags'>" +
    post.tags.map do |tag|
      "<a href='/#{tag.name}'>#{tag.name}</a>"
    end.join(', ') +
    "</p>"
  end
end

# stylesheets -----------

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"/../stylesheets/#{params[:name]}", :style => :compact, :load_paths => [File.join(Sinatra::Application.views, 'stylesheets')]
end

get '/stylesheets/plugins/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"#{PLUGINS_FOLDER}/#{params[:name]}/styles", :style => :compact
end

# auth -----------

get '/login/?' do
  haml :auth 
end

post '/login/?' do
  response.set_cookie(Geido.admin_cookie_key, Geido.admin_cookie_value) if params[:password] == Geido.admin_password
  redirect params[:jump] ? params[:jump] : "/"
end

get '/logout/?' do
  response.set_cookie(Geido.admin_cookie_key, nil)
  redirect "/"
end

# posts -----------

get "/" do
  @view = "index"
  @posts = Post.reverse_order(:created_at)
  haml :list
end

get "/posts/?" do
  redirect "/"
end

post "/posts/?" do
  auth!
  post = Post.create(params[:post])
  flash[:notice] = 'Post created'
  redirect "/posts/#{post.id}"
end

get "/posts/new" do
  auth!
  @post = Post.new
  haml :edit
end

get "/posts/:id/edit" do
  auth!
  @post = Post[params[:id]]
  haml :edit
end

get "/posts/:id" do
  @post = Post[params[:id]]
  haml :show
end

put "/posts/:id" do
  auth!
  post = Post[params[:id]]
  post.set(params[:post])
  post.save
  flash[:notice] = 'Post edited'
  redirect "/posts/#{post.id}"
end

delete "/posts/:id" do
  auth!
  @post = Post[params[:id]]
  @post.delete
  flash[:notice] = 'Post deleted'
  redirect '/'
end

# feed ------------

get '/feed/?' do
  @posts = Post.reverse_order(:created_at)
  last_modified( @posts.first.updated_on ) rescue nil
  builder :list
end

# tags -----------

get "/:name" do
  @tag    = Tag.first(:name => params[:name]) || not_found('Tag not found')
  @view   = @tag.name
  @plugin = @tag.plugin
  @posts  = @tag.posts_dataset.reverse_order(:created_at)
  haml (@plugin && @plugin.overrides_list?) ? :"#{PLUGINS_FOLDER}/#{@plugin.name}/list" : :list
end

get "/:name/:id" do
  @tag    = Tag.first(:name => params[:name]) || not_found('Tag not found')
  @plugin = @tag.plugin
  @post   = @tag.posts_dataset.first(:post_id => params[:id]) || not_found('Post not found')
  haml :show
end