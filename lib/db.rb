set :database, ENV['DATABASE_URL'] || 'sqlite://development.db'

migration 'Setup' do
  database.create_table :posts do
    primary_key :id
    text        :title
    text        :content
    text        :properties_json
    timestamp   :created_at
    timestamp   :updated_at
  end

  database.create_table :tags do
    primary_key :id
    varchar     :name, :null => false
  end

  database.create_table :taggings do
    primary_key :id
    integer     :tag_id,  :null => false
    integer     :post_id, :null => false
  end
end

migration 'Add draft flag' do
  database.alter_table :posts do
    add_column :draft, :boolean, :default => false
  end
end
