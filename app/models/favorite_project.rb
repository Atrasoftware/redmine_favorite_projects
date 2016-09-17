class FavoriteProject < ActiveRecord::Base
  unloadable

  validates_presence_of :project_id, :user_id
  validates_uniqueness_of :project_id, :scope => [:user_id]

  attr_accessible :project_id, :user_id if ActiveRecord::VERSION::MAJOR >= 4

  def self.favorite?(project_id, user_id=User.current.id)
    FavoriteProject.where(:project_id => project_id, :user_id => user_id).present?
  end
  def self.all_favorite(project_id, user_id=User.current.id)
    FavoriteProject.where(:project_id => project_id, :user_id => user_id).pluck(:project_id)
  end
end
