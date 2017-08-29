require_dependency 'query'

module RedmineFavoriteProjects
  module Patches
    module QueryPatch
      def self.included(base) # :nodoc:
        base.include(InstanceMethods)
        base.class_eval do
          unloadable

          class<< self
          end

        end
      end


    end

    module InstanceMethods

      def project_custom_fields
        if project
          project.visible_custom_field_values.map(&:custom_field)
        else
          ProjectCustomField.where(visible: true)
        end
      end


    end
  end
end

unless Query.included_modules.include?(RedmineFavoriteProjects::Patches::QueryPatch)
  Query.send(:include, RedmineFavoriteProjects::Patches::QueryPatch)
end
