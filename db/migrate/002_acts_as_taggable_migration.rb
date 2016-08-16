class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_taggable_table
  end

  def self.down

  end
end