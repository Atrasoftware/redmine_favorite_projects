require_dependency 'project'

module RedmineFavoriteProjects
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.class_eval do
          unloadable
          safe_attributes 'tag_list'
          rcrm_acts_as_taggable

          class<< self
            alias_method_chain :project_tree, :order
            alias_method_chain :next_identifier, :year
          end
        end
      end
    end
    module ClassMethods
      def next_identifier_with_year
        year = Date.today.year
        p = Project.where("YEAR(created_on) >= ?", year ).count

        # p = Project.order('id DESC').first
        # p.nil? ? nil : p.identifier.to_s.succ
        "c#{year%2000}#{"%03d" % p.succ}"
      end
      def project_tree_with_order(projects, &block)
        ancestors = []
        setting = Setting.plugin_redmine_favorite_projects
        sort = :lft
        if setting['sort_criteria'].present?
          sort = setting['sort_criteria'].to_sym
        end
        projects.sort_by(&sort).each do |project|
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last))
            ancestors.pop
          end
          yield project, ancestors.size
          ancestors << project
        end
      end
    end
  end
end

unless Project.included_modules.include?(RedmineFavoriteProjects::Patches::ProjectPatch)
  Project.send(:include, RedmineFavoriteProjects::Patches::ProjectPatch)
end
