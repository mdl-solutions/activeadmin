module ActiveAdmin
  module Views
    class TitleBar < Component

      def build(title, action_items)
        build_breadcrumb
        # super(id: "title_bar", class: 'd-flex')
        @title = title
        @action_items = action_items
        span id: "title_bar", class: 'd-flex' do
          build_titlebar_left
          build_titlebar_right
        end
      end

      private

      def build_titlebar_left
        div id: "titlebar_left", class: 'flex-grow-1' do
          build_title_tag
        end
      end

      def build_titlebar_right
        div id: "titlebar_right" do
          build_action_items
        end
      end

      def build_breadcrumb(separator = "/")
        breadcrumb_config = active_admin_config && active_admin_config.breadcrumb

        links = if breadcrumb_config.is_a?(Proc)
                  instance_exec(controller, &active_admin_config.breadcrumb)
                elsif breadcrumb_config.present?
                  breadcrumb_links
                end
        if links.present? && links.is_a?(::Array)
          nav 'aria-label': "breadcrumb" do
            ol class: 'breadcrumb mt-3' do
              links.each do |link|
                li(link, class: 'breadcrumb-item')
                # span(separator, class: "breadcrumb_sep")
              end
            end
          end
        else
          div class: 'mb-2' # Push the page title down a little bit
        end
      end

      def build_title_tag
        h2(@title, id: "page_title", class: 'mb-3')
      end

      def build_action_items
        insert_tag(view_factory.action_items, @action_items)
      end

    end
  end
end
