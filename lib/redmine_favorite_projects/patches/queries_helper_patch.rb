require_dependency 'queries_helper'
require_dependency 'application_helper'

module RedmineFavoriteProjects
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :column_value, :favorite_projects
        end
      end


      module InstanceMethods
        def column_value_with_favorite_projects(column, list_object, value)
          if column.name == :id  && list_object.is_a?(Project)
            link_to value, project_path(value)
          elsif column.name == :name && list_object.is_a?(Project)
            content_tag(:span, link_to_project_without_identifier(list_object, {:action => 'show'}, :title => list_object.short_description))
          elsif column.name == :description && list_object.is_a?(Project)
            content_tag(:span, list_object.short_description)
          elsif column.name == :created_on && list_object.is_a?(Project)
            format_date(list_object.created_on)
          elsif column.name == :status && list_object.is_a?(Project)
            case value
            when Project::STATUS_ACTIVE
              l(:project_status_active)
            when Project::STATUS_CLOSED
              l(:project_status_closed)
            when Project::STATUS_ARCHIVED
              l(:project_status_archived)
            else
              value
            end
          elsif column.name == :tags && list_object.is_a?(Project)
            project_tags = []
            value.each do |tag|
              project_tags << tag.name
            end
            project_tags.join(", ")
          else
            column_value_without_favorite_projects(column, list_object, value)
          end
        end

      end

    end
  end
end

unless QueriesHelper.included_modules.include?(RedmineFavoriteProjects::Patches::QueriesHelperPatch)
  QueriesHelper.send(:include, RedmineFavoriteProjects::Patches::QueriesHelperPatch)
end