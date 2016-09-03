require_dependency 'application_helper'

module RedmineFavoriteProjects
  module Patches

    module ApplicationHelperPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :render_project_jump_box, :only_favorites
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def render_project_jump_box_with_only_favorites
          return unless User.current.logged?
          favorite_projects = FavoriteProject.where(:user_id => User.current.id)
          favorite_projects_ids = favorite_projects.pluck(:project_id)
          project_ids = User.current.memberships.where(project_id: favorite_projects_ids).pluck(:project_id)
          projects = Project.active.where(id: project_ids)
          # projects = User.current.memberships.collect(&:project).compact.uniq.select{|p| favorite_projects_ids.include?(p.id) && p.active? }
          projects = projects.any? ? projects : Project.visible.active

          if projects.any?
            options =
                ("<option value=''>#{ l(:label_jump_to_a_project) }</option>" +
                    '<option value="" disabled="disabled">---</option>').html_safe

            options << project_tree_options_for_select(projects, :selected => @project) do |p|
              { :value => project_path(:id => p, :jump => current_menu_item) }
            end
            select_tag('project_quick_jump_box', options, :onchange => 'if (this.value != \'\') { window.location = this.value; }')
          end
        end

      end

    end
  end
end


unless ApplicationHelper.included_modules.include?(RedmineFavoriteProjects::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineFavoriteProjects::Patches::ApplicationHelperPatch)
end
