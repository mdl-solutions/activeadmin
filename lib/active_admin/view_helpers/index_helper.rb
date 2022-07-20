module ActiveAdmin
  module ViewHelpers
    module IndexHelper

      def index_tabs
        div class: 'card' do
          div class: 'card-header d-flex pe-0' do
            # span('Overzicht', { class: 'py-2 flex-grow-1' })
            # a([i('', { class: 'me-1 fas fa-cogs' }), text_node('Batch acties')], { href: '#', class: 'btn disabled' })
            # a([i('', { class: 'me-1 fas fa-columns' }), text_node('Kolommen')], { href: '#columns', class: 'btn', role: 'button', 'data-bs-toggle': 'collapse' })
            # a([i('', { class: 'me-1 fas fa-filter' }), text_node('Filters'), span('4', { class: 'ms-1 badge bg-light text-dark' })], { href: '#filters', class: 'btn', role: 'button', 'data-bs-toggle': 'collapse' })
            ul class: 'nav nav-tabs card-header-tabs' do
              # li class: 'nav-item' do
              #   a class: 'nav-link active', id: 'nav-index-tab', role: 'button', href: '#nav-index', 'data-bs-toggle': 'tab', 'aria-current': true do
              #     [
              #       i('', { class: 'me-1 fas fa-list' }),
              #       text_node('Overzicht'),
              #     ]
              #   end
              # end
              active_admin_config.page_presenters[:index]&.each do |name, presenter|
                is_current = current_index?(name.to_s)
                
                params = request.query_parameters.except :page, :commit, :format
                link = is_current ? "\#nav-index-#{name}" : url_for(**params.merge(as: name).to_h.symbolize_keys)
                
                icon = presenter.options[:icon] || 'list'
                
                li class: 'nav-item' do
                  extra_options = is_current ? { role: 'button', 'data-bs-toggle': 'tab', 'aria-current': true } : {}
                  a({class: "nav-link#{is_current ? ' active' : ''}", id: "nav-index-tab", href: link}.merge(extra_options)) do
                    [
                      i('', { class: "me-1 fas fa-#{icon}" }),
                      text_node(I18n.t("active_admin.index_list.#{name}")),
                    ]
                  end
                end
              end
              li class: 'nav-item' do
                a class: 'nav-link', id: 'nav-filters-tab', role: 'button', href: '#nav-filters', 'data-bs-toggle': 'tab' do
                  [
                    i('', { class: 'me-1 fas fa-filter' }),
                    text_node('Filters'),
                    # span('4', { class: 'ms-1 badge bg-light text-dark' }),
                  ]
                end
              end
              # if current_index?('table')
              #   li class: 'nav-item' do
              #     a class: 'nav-link', id: 'nav-columns-tab', role: 'button', href: '#nav-columns', 'data-bs-toggle': 'tab' do
              #       [
              #         i('', { class: 'me-1 fas fa-columns' }),
              #         text_node('Kolommen'),
              #       ]
              #     end
              #   end
              # end
            end
          end
          # div id: 'filters', class: 'card-body bg-light border-bottom' do
          #   span('Filters')
          # end
          # div id: 'columns', class: 'card-body bg-light border-bottom' do
          #   span('Kolommen')
          # end
          
          div class: "card-body" do
            div class: 'tab-content', id: 'nav-tabContent' do
              div class: 'tab-pane fade show active', id: "nav-index-#{current_index_name}", role: 'tabpanel', 'aria-labelledby': 'nav-index-tab' do
                yield
              end
              div class: 'tab-pane fade', id: 'nav-filters', role: 'tabpanel', 'aria-labelledby': 'nav-filters-tab' do
                # sidebar_sections_for_action = []
                # if active_admin_config && active_admin_config.sidebar_sections?
                #   sidebar_sections_for_action = active_admin_config.sidebar_sections_for(params[:action], self)
                # end
                
                # sidebar sidebar_sections_for_action, id: "sidebar" unless skip_sidebar?
              end
              div class: 'tab-pane fade', id: 'nav-columns', role: 'tabpanel', 'aria-labelledby': 'nav-columns-tab' do
              end
            end
          end
        end
      end

      def current_index_name
        if params[:as].present?
          params[:as]
        elsif active_admin_config.page_presenters[:index]&.count == 1
          active_admin_config.page_presenters[:index].keys.first
        else
          active_admin_config.default_index_class&.index_name
        end
      end
      
      def current_index?(index_name)
        index_name == current_index_name
      end

    end
  end
end
