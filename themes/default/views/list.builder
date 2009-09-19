xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "http://geido.heroku.com"
  xml.link :type => 'text/html', :href => "http://geido.heroku.com", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://geido.heroku.com/feed", :rel => 'self'
  xml.title "Geido"
  xml.subtitle "geido.heroku.com"
  xml.updated(@posts.first ? @posts.first.created_at : Time.now.utc)
  @posts.each do |post|
    xml.entry do |entry|
      entry.id "http://geido.heroku.com/#{post.id}"
      entry.link :type => 'text/html', :href => "http://geido.heroku.com/#{post.id}", :rel => 'alternate'
      entry.updated post.created_at
      entry.title post.title
      entry.content post.content,  :type => 'html'
    end
  end
end