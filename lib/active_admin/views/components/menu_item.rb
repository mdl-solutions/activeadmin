module ActiveAdmin
  module Views

    # Arbre component used to render ActiveAdmin::MenuItem
    class MenuItem < Component
      builder_method :menu_item
      attr_reader :label
      attr_reader :url
      attr_reader :priority
      attr_reader :icon

      def build(item, options = {})
        super(options.merge(id: item.id))
        @label = helpers.render_in_context self, item.label
        @url = helpers.render_in_context self, item.url
        @priority = item.priority
        @submenu = nil
        
        visible_child_items = item.items.select{|i| helpers.render_in_context(self, i.should_display) }
        if visible_child_items.count == 1
          @url = helpers.render_in_context self, visible_child_items.first.url
        end
        
        is_current = item.current? assigns[:current_tab]
        add_class "current" if is_current
        
        sub_menu_id = "#{item.id.gsub(/\W/,'')}-sub"
        
        if url
          item_options = item.html_options.merge(class: 'ps-0 btn')
          if visible_child_items.count > 1
            item_options.merge!(href: "##{sub_menu_id}", role: 'button', data: { 'bs-toggle': 'collapse' }, 'aria-expanded': is_current.to_s, 'aria-controls': sub_menu_id)
            # item_options.merge!(role: 'button', data: { 'bs-toggle': 'collapse', 'bs-target': '##{item.id}-sub' }, 'aria-expanded': is_current.to_s, 'aria-controls': "#{item.id}-sub")
          end
          label_text = label
          if item.icon.present?
            label_text = "<i class=\"far fa-#{item.icon} fa-fw me-3\" data-fa-transform=\"down-3\"></i>#{label}".html_safe
          end
          text_node link_to label_text, url, **item_options
        else
          span label, item.html_options
        end
        
        if visible_child_items.count > 1
          add_class "has_nested"
          @submenu = menu(item, { id: "#{sub_menu_id}", class: "list-unstyled collapse #{is_current ? ' show' : ''}" })
        end
      end

      def tag_name
        "li"
      end

      # Sorts by priority first, then alphabetically by label if needed.
      def <=>(other)
        result = priority <=> other.priority
        result == 0 ? label <=> other.label : result
      end

      def visible?
        url.nil? || real_url? || @submenu && @submenu.children.any?
      end

      def to_s
        visible? ? super : ""
      end

      private

      # URL is not nil, empty, or '#'
      def real_url?
        url && url.present? && url != "#"
      end
    end
  end
end
