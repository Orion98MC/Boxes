module Boxes
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    
    source_root File.expand_path('../templates', __FILE__)
    argument :model_name, :type => :string, :default => 'MetaBox'
    
    def make_migration
      migration_template 'migration.rb', "db/migrate/create_#{plural_name}.rb"
    end
    
    private
    def plural_name
      model_name.underscore.pluralize
    end

    # Beurk!
    def self.next_migration_number(dirname) #:nodoc:
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end
  end
end