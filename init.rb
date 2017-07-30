requires_redmine_crm :version_or_higher => '0.0.22' rescue raise "\n\033[31mRedmine requires newer redmine_crm gem version.\nPlease update with 'bundle update redmine_crm'.\033[0m"

FP_VERSION_NUMBER = '2.0.3'

require 'redmine'
require 'redmine_favorite_projects'

Redmine::Plugin.register :redmine_favorite_projects do
  name 'Redmine Favorite Projects plugin'
  author 'RedmineCRM'
  description 'This is a favorite projects plugin for Redmine'
  version FP_VERSION_NUMBER
  url 'http://redminecrm.com/projects/favoriteprojects'
  author_url 'mailto:support@redminecrm.com'

  requires_redmine :version_or_higher => '2.3'

  project_module :favorite_projects do
    permission :manage_public_favorite_project_queries, {}, :require => :loggedin
    permission :manage_favorite_project_queries, {}, :require => :loggedin
  end

  settings :default => {
    :default_list_style => 'list',
    :favorite_projects_list_default_columns => [:name, :description, :created_on],
  }, :partial => 'settings/favorite_projects/general'

end

