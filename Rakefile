require 'main'

task :populate do
  [
    {
      :title => 'Example Plugin Post',
      :tags_str => 'example',
      :properties => { :color => 'red', :subtitle => 'this is my fancy subtitle' },
      :content => 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
    },
    {
      :title => 'Video Post',
      :tags_str => 'video',
      :properties => { :url => 'http://vimeo.com/2910103' },
      :content => 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim laborum.'
    },
    {
      :title => 'Draft Post',
      :tags_str => '',
      :content => 'Aenean arcu erat, pellentesque vel tristique sit amet, rutrum vitae elit. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed sit amet neque urna, id elementum odio. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam vehicula mi eu lectus laoreet eleifend. Etiam rutrum nibh lobortis nisl posuere commodo.',
      :draft => true
    }
  ].each do |attrs|
    p = Post.new
    p.set(attrs)
    p.save
  end
end