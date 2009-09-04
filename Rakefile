require 'main'

task :populate do
  [
    {
      :title => 'First Post, Huzzah!',
      :tags_str => 'example',
      :properties => { :color => 'red', :subtitle => 'this is my fancy subtitle' },
      :content => 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
    },
    {
      :title => 'Video Post',
      :tags_str => 'video',
      :properties => { :url => 'http://vimeo.com/2910103' },
      :content => 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim laborum.'
    }
  ].each do |attrs|
    p = Post.new
    p.set(attrs)
    p.save
  end
end