class Tag < Sequel::Model
  one_to_many :taggings
  many_to_many :posts, :join_table => :taggings

  def css
    return unless plugin && plugin.has_css?
    "plugins/#{plugin.name}.css"
  end

  def plugin
    @plugin ||= Plugin.get(name)
  end
end