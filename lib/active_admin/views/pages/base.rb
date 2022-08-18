module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document

        def build(*args)
          set_attribute :lang, I18n.locale
          build_active_admin_head
          build_page
        end

        alias_method :html_title, :title # Arbre::HTML::Title
        def title
          self.class.name
        end

        def main_content
          I18n.t("active_admin.main_content", model: title).html_safe
        end

        private

        delegate :active_admin_config, :controller, :params, to: :helpers

        def build_active_admin_head
          within head do
            html_title [title, helpers.active_admin_namespace.site_title(self)].compact.join(" | ")

            text_node(active_admin_namespace.head)

            active_admin_application.stylesheets.each do |style, options|
              stylesheet_tag = active_admin_namespace.use_webpacker ? stylesheet_pack_tag(style, **options) : stylesheet_link_tag(style, **options)
              text_node(stylesheet_tag.html_safe) if stylesheet_tag
            end

            active_admin_namespace.meta_tags.each do |name, content|
              text_node(meta(name: name, content: content))
            end

            active_admin_application.javascripts.each do |path|
              javascript_tag = active_admin_namespace.use_webpacker ? javascript_pack_tag(path) : javascript_include_tag(path)
              text_node(javascript_tag)
            end

            if active_admin_namespace.favicon
              text_node(favicon_link_tag(active_admin_namespace.favicon))
            end

            text_node csrf_meta_tag
          end
        end

        def build_page
          within body(class: body_classes) do
            div class: "container-fluid" do
              div id: 'top-bar', class: "row fixed-top" do
                @utility_menu = active_admin_namespace.fetch_menu(:utility_navigation)
                
                div class: 'd-flex' do
                  div class: 'p-2 flex-grow-1' do
                    site_title active_admin_namespace
                  end
                  # div class: 'p-2' do
                  #   utility_navigation @utility_menu, id: "utility_nav", class: "header-item tabs"
                  # end
                  button class: 'navbar-toggler', type: 'button', 'data-bs-toggle': 'collapse', 'data-bs-target': '#main-sidebar', 'aria-controls': 'mai-sidebar', 'aria-expanded': false, 'aria-label': 'Toggle navigation' do
                    span class: 'navbar-toggler-icon'
                  end
                  build_navbar
                end
              end
              div id: 'main-wrapper', class: "d-flex" do
                div id: 'main-sidebar', class: "ps-2 min-vh-100" do
                  header active_admin_namespace, current_menu
                end
                div id: 'main-content', class: "px-2 flex-fill" do
                  title_bar title, action_items_for_action
                  build_page_content
                  footer active_admin_namespace
                end
              end
            end
          end
        end

        def body_classes
          Arbre::HTML::ClassList.new [
            params[:action],
            params[:controller].tr("/", "_"),
            "active_admin", "logged_in",
            active_admin_namespace.name.to_s + "_namespace"
          ]
        end

        def build_unsupported_browser
          if active_admin_namespace.unsupported_browser_matcher =~ controller.request.user_agent
            unsupported_browser
          end
        end

        def build_navbar
        end

        def build_page_content
          build_flash_messages
          div id: "active_admin_content", class: (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
            build_main_content_wrapper
            sidebar sidebar_sections_for_action, id: "sidebar" unless skip_sidebar?
          end
        end

        def build_flash_messages
          div class: "flashes" do
            flash_messages.each do |type, messages|
              [*messages].each do |message|
                div message, class: "flash flash_#{type}"
              end
            end
          end
        end

        def build_main_content_wrapper
          div id: "main_content_wrapper" do
            div id: "main_content" do
              main_content
            end
          end
        end

        # Returns the sidebar sections to render for the current action
        def sidebar_sections_for_action
          if active_admin_config && active_admin_config.sidebar_sections?
            active_admin_config.sidebar_sections_for(params[:action], self)
          else
            []
          end
        end

        def action_items_for_action
          if active_admin_config && active_admin_config.action_items?
            active_admin_config.action_items_for(params[:action], self)
          else
            []
          end
        end

        def skip_sidebar?
          sidebar_sections_for_action.empty? || assigns[:skip_sidebar] == true
        end

      end
    end
  end
end
