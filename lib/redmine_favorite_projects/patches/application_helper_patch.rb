require_dependency 'application_helper'

module RedmineFavoriteProjects
  module Patches

    module ApplicationHelperPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable 
          alias_method_chain :render_project_jump_box, :only_favorites
          alias_method_chain :link_to_project, :identifier
        end
      end

      module InstanceMethods
        def link_to_project_with_identifier(project, options={}, html_options = nil)
          if project.archived?
            h(project.to_s)
          else
            link_to project.to_s,
                    project_url(project, {:only_path => true}.merge(options)),
                    html_options
          end
        end

        # Adds a rates tab to the user administration page
        def render_project_jump_box_with_only_favorites
          return unless User.current.logged?
          favorite_projects_ids = FavoriteProject.where(:user_id => User.current.id).map(&:project_id)
          projects = Project.active.visible.where(:id => favorite_projects_ids)

          projects = Project.active.visible unless projects.any?

          if projects.any?
            s = '<select id="project_quick_jump_box" onchange="if (this.value != \'\') { window.location = this.value; }">' +
            "<option value=''>#{ l(:label_jump_to_a_project) }</option>" +
            '<option value="" disabled="disabled">---</option>'
            s << project_tree_options_for_select(projects, :selected => @project) do |p|
              { :value => url_for(:controller => 'projects', :action => 'show', :id => p, :jump => current_menu_item) } 
            end
            s << '</select>'
            s.html_safe
          end        
        end
        
      end

    end
  end
end


unless ApplicationHelper.included_modules.include?(RedmineFavoriteProjects::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineFavoriteProjects::Patches::ApplicationHelperPatch)
end
