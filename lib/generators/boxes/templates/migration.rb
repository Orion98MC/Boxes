class Create<%= plural_name.camelize %> < ActiveRecord::Migration
  def self.up
    create_table :<%= plural_name %> do |t|
      t.string  :address, :null => false
      t.integer :parent_id
      t.integer :position
      t.boolean :published, :default => true
      t.text    :html_options
      t.string  :wclass
      t.string  :wname
      t.string  :wstate
      t.text    :wopts

      t.timestamps
    end
  end

  def self.down
    drop_table :<%= plural_name %>
  end
end
