require 'rubygems'
require 'sinatra'
require 'builder'
require 'sinatra/sequel'
require 'redcloth'
require 'haml'
require 'sass'
require 'json'
require 'rack-flash'

require 'config'

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'plugin'
require 'db'
require 'post'
require 'tag'
require 'tagging'

Plugin.load!

use Rack::Session::Cookie
use Rack::Flash

configure :production do
  # use custom error handling 
  set :raise_errors, Proc.new { false }
  set :show_exceptions, false
end

set :views,  File.expand_path(File.dirname(__FILE__), "themes/#{Geido.theme}/views")
set :public, File.expand_path(File.dirname(__FILE__), "themes/#{Geido.theme}/public")
PLUGINS_FOLDER = '/../../../plugins' # location of the plugins folder, must be relative to views

custom_theme_routes = "#{File.dirname(__FILE__)}/themes/#{Geido.theme}/routes.rb"
require custom_theme_routes if File.exists?(custom_theme_routes)

helpers do
  def partial(page, options={})
    haml "_#{page}".to_sym, options.merge!(:layout => false)
  end

  def user_admin_theme
    set :views,  File.expand_path(File.dirname(__FILE__), "themes/admin/views")
    set :public, File.expand_path(File.dirname(__FILE__), "themes/admin/public")
  end

  def admin?
    @admin ||= (request.cookies[Geido.admin_cookie_key] == Geido.admin_cookie_value)
  end

  def auth!
    user_admin_theme
    redirect "/login?jump=#{request.env['REQUEST_URI']}" unless admin?
  end

  def admin
    yield if admin?
  end

  def admin_links(post)
    return unless admin?
    "<form class='admin menu' method='POST' action='/admin/posts/#{post.id}'>
      <a href='/admin/posts/#{post.id}/edit'>Edit</a>
      <input type='hidden' name='_method' value='DELETE' />
      <input type='submit' value='Delete' />
    </form>"
  end

  def date(post)
    "<p class='created_at'>#{post.created_at.strftime('%e %B %Y')}</p>"
  end
  
  def tags(post)
    return if post.tags.empty?
    "<p class='tags'>" +
    post.tags.map do |tag|
      "<a href='/#{tag.name}'>#{tag.name}</a>"
    end.join(', ') +
    "</p>"
  end
end

# == ADMIN ================================================================================

get '/admin/stylesheets/:name.css' do
  user_admin_theme
  content_type 'text/css', :charset => 'utf-8'
  sass :"/../stylesheets/#{params[:name]}", :style => :compact, :load_paths => [File.join(Sinatra::Application.views, 'stylesheets')]
end

# auth -----------

get '/login/?' do
  user_admin_theme
  @view = "login"
  haml :auth
end

post '/login/?' do
  user_admin_theme
  response.set_cookie(Geido.admin_cookie_key, Geido.admin_cookie_value) if params[:password] == Geido.admin_password
  redirect params[:jump] ? params[:jump] : "/admin/posts"
end

get '/logout/?' do
  user_admin_theme
  response.set_cookie(Geido.admin_cookie_key, nil)
  redirect "/"
end

# list posts -----------

get "/admin/?" do
  auth!
  redirect '/admin/posts'
end

get "/admin/posts/?" do
  auth!
  @view = "list"
  @posts = Post.dataset
  haml :list
end

# create, edit posts ------------

post "/admin/posts/?" do
  auth!
  post = Post.create(params[:post])
  flash[:notice] = 'Post created'
  redirect "/admin/posts"
end

get "/admin/posts/new" do
  auth!
  @view = "create"
  @post = Post.new
  haml :edit
end

get "/admin/posts/:id/edit" do
  auth!
  @view = "edit"
  @post = Post[params[:id]]
  haml :edit
end

put "/admin/posts/:id" do
  auth!
  post = Post[params[:id]]
  post.set(params[:post])
  post.save
  flash[:notice] = 'Post edited'
  redirect "/admin/posts"
end

# delete posts -----------------------------------

delete "/admin/posts/:id" do
  auth!
  @post = Post[params[:id]]
  @post.delete
  flash[:notice] = 'Post deleted'
  redirect '/admin/posts'
end


## == PUBLIC ===================================================================================

error do
  @e = request.env['sinatra.error']
  status @e.status_code if @e.respond_to?(:status_code)
  haml :error
end

class NotFound < RuntimeError
  def status_code
    404
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

# posts -----------

get "/" do
  @view = "index"
  @posts = Post.published
  haml :list
end

get "/posts/?" do
  @view = "list"
  @posts = Post.published
  haml :list
end

get "/posts/:id" do
  @view = "show"
  @post = Post[params[:id]]
  haml :show
end

# feed ------------

get '/feed/?' do
  @posts = Post.published
  last_modified( @posts.first.updated_on ) rescue nil
  builder :list
end

# tags -----------

get "/:name" do
  @tag    = Tag.first(:name => params[:name]) || raise(NotFound, 'Tag not found')
  @view   = @tag.name
  @plugin = @tag.plugin
  @posts  = @tag.posts_dataset.published
  haml (@plugin && @plugin.overrides_list?) ? :"#{PLUGINS_FOLDER}/#{@plugin.name}/list" : :list
end

get "/:name/:id" do
  @tag    = Tag.first(:name => params[:name]) || raise(NotFound, 'Tag not found')
  @plugin = @tag.plugin
  @post   = @tag.posts_dataset.first(:post_id => params[:id]) || raise(NotFound, 'Post not found')
  haml :show
end