class Plugin
  def self.load!
    @@plugins = {}
    Dir[File.dirname(__FILE__) + '/../plugins/*'].each do |folder|
      name = folder.gsub(/.*\//, '')
      require folder + '/' + name
      begin
        @@plugins[name] = Kernel.const_get(name.capitalize).new(folder)
        Tag.find_or_create(:name => name) # make sure we have a tag for it
      rescue NameError
        raise "Plugin error: expected #{folder}/#{name}.rb to implement #{name.capitalize}"
      end
    end
  end

  def self.get(name)
    @@plugins[name]
  end

  def self.all
    @@plugins
  end

  def initialize(path)
    @path = path
  end

  def name
    self.class.name.downcase
  end

  def properties
    []
  end

  def has_css?
    File.exists? "#{@path}/styles.sass"
  end

  def has_content_partial?
    File.exists? "#{@path}/_content.haml"
  end

  def render_content(app, post)
    return unless has_content_partial?
    Haml::Engine.new(File.read("#{@path}/_content.haml")).render(app, :post => post)
  end

  def overrides_post?
    File.exists? "#{@path}/_post.haml"
  end

  def render_post(app, post)
    return unless overrides_post?
    Haml::Engine.new(File.read("#{@path}/_post.haml")).render(app, { :post => post, :plugin => self })
  end

  def overrides_list?
    File.exists? "#{@path}/list.haml"
  end

  def to_json
    properties.to_json
  end

  # properties ---
  def columns
    properties.map do |property|
      property.is_a?(Array) ? property : text(property)
    end
  end

  def text(name)
    [name, :text]
  end

  def textarea(name)
    [name, :textarea]
  end
end