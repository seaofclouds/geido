class Video < Plugin
  def self.default_dimensions
    [560, 340]
  end
  def self.embed(post)
    width, height = parse_dimensions(post)
    url  = post.properties['url']
    host = url.match(/(\w+)\.com/)
    raise "Invalid URL: #{url}" if !host || !host[1]
    raise "Don't know how to embed #{host[1]}" if !respond_to?("embed_#{host[1]}")
    send("embed_#{host[1]}", url, width, height)
  end

  def self.embed_youtube(url, width, height)
    id = url.match(/\?v=(\w+)/)[1]
    color1 = '2b405b'
    color2 = '6b8ab6'
    resource_url = "http://www.youtube.com/v/#{id}&hl=en&fs=1&color1=0x#{color1}&color2=0x#{color2}"

    "<object width='#{width}' height='#{height}'>
      <param name='movie' value='#{resource_url}'></param>
      <param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param>
      <embed src='#{resource_url}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='#{width}' height='#{height}'></embed>
    </object>"
  end

  def self.embed_vimeo(url, width, height)
    id = url.match(/\/(\d+)/)[1]
    show_title    = 1
    show_byline   = 1
    show_portrait = 0
    fullscreen    = 1
    color         = '' # hexcode
    resource_url  = "http://vimeo.com/moogaloop.swf?clip_id=#{id}&amp;server=vimeo.com&amp;show_title=#{show_title}&amp;show_byline=#{show_byline}&amp;show_portrait=#{show_portrait}&amp;color=#{color}&amp;fullscreen=#{fullscreen}"

    "<object width='#{width}' height='#{height}'>
       <param name='allowfullscreen' value='true' />
       <param name='allowscriptaccess' value='always' />
       <param name='movie' value='#{resource_url}' />
       <embed src='#{resource_url}' type='application/x-shockwave-flash' allowfullscreen='true' allowscriptaccess='always' width='#{width}' height='#{height}'></embed>
    </object>"
  end

  def self.parse_dimensions(post)
    %w( width height ).map do |attr|
      val = post.properties[attr].to_i
      return self.default_dimensions if val == 0
      val
    end
  end

  def properties
    [:url, :width, :height]
  end
end