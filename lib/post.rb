class Post < Sequel::Model
  one_to_many  :taggings
  many_to_many :tags, :join_table => :taggings, :order => :name
  
  def slug
    @slug ||= title.downcase.gsub(/ /, '-').gsub(/[^a-z0-9\-]/, '').squeeze('-')
  end
  
  def tags_str=(tags)
    @tags_to_save = tags.split(/[\s,]+/)
  end

  def tags_str
    new? ? [] : tags.map { |t| t.name }.join(', ')
  end

  def properties
    JSON.parse(properties_json || '{}')
  end

  def properties=(properties)
    self.properties_json = properties.to_json
  end

  def default_plugin
    tags.each { |t| return t.plugin if t.plugin }
    nil
  end

  def render(app, plugin=nil)
    plugin ||= default_plugin
    if plugin && plugin.overrides_post?
      plugin.render_post(app, self)
    else
      Haml::Engine.new(File.read("#{app.options.views}/_post.haml")).render(app, :post => self, :plugin => plugin)
    end
  end

  def after_save
    @tags_to_save.each do |tag_name|
      tag = Tag.find_or_create(:name => tag_name)
      Tagging.find_or_create(:post_id => id, :tag_id => tag.id)
    end
    taggings.reject { |t| @tags_to_save.include? t.tag.name }.each { |t| t.destroy }
  end

  def before_create
    self.created_at = Time.now
    self.updated_at = Time.now
  end
  def before_save
    self.updated_at = Time.now
  end

  def method_missing(method, *args)
    return super unless args.empty? && properties.has_key?(method.to_s)
    properties[method.to_s]
  end
end