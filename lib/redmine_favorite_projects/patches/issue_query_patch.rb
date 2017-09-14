require_dependency 'issue_query'

module RedmineFavoriteProjects
  module Patches
    module IssueQueryPatch
      def self.included(base) # :nodoc:
        base.include(InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :available_columns, :project

        end
      end


    end

    module InstanceMethods
      def available_columns_with_project
        return @available_columns if @available_columns
        @available_columns = available_columns_without_project
        match =  @available_columns.find{|c| c.name == :project}
        @available_columns[@available_columns.index(match)] = QueryColumn.new(:project, :sortable => "#{Project.table_name}.identifier_with_cfs", :groupable => true)
        @available_columns += project_custom_fields.collect {|cf| QueryCustomFieldColumn.new(cf) }
        @available_columns
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineFavoriteProjects::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineFavoriteProjects::Patches::IssueQueryPatch)
end
