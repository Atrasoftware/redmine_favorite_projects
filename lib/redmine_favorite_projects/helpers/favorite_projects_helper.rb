module RedmineFavoriteProjects
  module Helper

    def favorite_project_tag_url(tag_name, options={})
      {:controller => 'favorite_projects',
       :action => 'search',
       :set_filter => 1,
       :fields => [:tags],
       :values => {:tags => [tag_name]},
       :operators => {:tags => '='}
      }.merge(options)
    end

    def favorite_project_tag_link(tag_name, options={})
      style = RedmineFavoriteProjects.settings[:monochrome_tags].to_i > 0 ? {} : {:style => "background-color: #{favorite_project_tag_color(tag_name)}"}
      tag_count = options.delete(:count)
      tag_title = tag_count ? "#{tag_name} (#{tag_count})" : tag_name
      link = link_to tag_title, favorite_project_tag_url(tag_name), options
      content_tag(:span, link, {:class => "tag-label-color"}.merge(style))
    end

    def favorite_project_tag_color(tag_name)
      "##{"%06x" % (tag_name.unpack('H*').first.hex % 0xffffff)}"
      # "##{"%06x" % (Digest::MD5.hexdigest(tag_name).hex % 0xffffff)}"
      # "##{"%06x" % (tag_name.hash % 0xffffff).to_s}"
    end

    def favorite_project_tag_links(tag_list, options={})
      content_tag(
                :span,
                tag_list.map{|tag| favorite_project_tag_link(tag, options)}.join(' ').html_safe,
                :class => "tag_list") if tag_list
    end

    def favorite_project_tagsedit_with_source_for(field_id, url)
      s = ""
      unless @favorite_project_tagsedit_with_source_for
        s << javascript_include_tag(:"tag-it", :plugin => 'redmine_favorite_projects')
        s << stylesheet_link_tag(:"jquery.tagit.css", :plugin => 'redmine_favorite_projects')
        @favorite_project_tagsedit_with_source_for = true
      end
      s << javascript_tag("$('#{field_id}').tagit({
          tagSource: function(search, showChoices) {
            var that = this;
            $.ajax({
            url: '#{url}',
            data: {q: search.term},
            success: function(choices) {
              showChoices(that._subtractArray(jQuery.parseJSON(choices), that.assignedTags()));
            }
            });
          },
          allowSpaces: true,
          placeholderText: '#{l(:label_favorite_project_add_tag)}',
          caseSensitive: false,
          removeConfirmation: true
        });")
      s.html_safe
    end


  end
end

ActionView::Base.send :include, RedmineFavoriteProjects::Helper
