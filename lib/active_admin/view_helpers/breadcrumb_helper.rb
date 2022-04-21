module ActiveAdmin
  module ViewHelpers
    module BreadcrumbHelper

      # Returns an array of links to use in a breadcrumb
      def breadcrumb_links(path = request.path)
        # remove leading "/" and split up the URL
        parts = path.split("/").select(&:present?)

        parts.each_with_index.map do |part, index|
          # 1. try using `display_name` if we can locate a DB object
          # 2. try using the model name translation
          # 3. default to calling `titlecase` on the URL fragment
          if part =~ /\A(\d+|[a-f0-9]{24}|(?:[a-f0-9]{8}-(?:[a-f0-9]{4}-){3}[a-f0-9]{12}))\z/ && parts[index - 1]
            parent = active_admin_config.belongs_to_config.try :target
            config = parent && parent.resource_name.route_key == parts[index - 1] ? parent : active_admin_config
            name = display_name config.find_resource part
          end
          name ||= I18n.t "activerecord.models.#{part.singularize}", count: ::ActiveAdmin::Helpers::I18n::PLURAL_MANY_COUNT, default: part.titlecase
          if ['edit', 'show'].include?(name.downcase)
            name = I18n.t("active_admin.#{name.downcase}")
          elsif name.downcase == 'new'
            model_name = I18n.t("activerecord.models.#{parts[index - 1].singularize}", count: 1)
            name = I18n.t("active_admin.new_model", model: model_name)
          end
          
          # Don't create a link if the resource's show action is disabled or if this is the final part
          if (!config || config.defined_actions.include?(:show)) && index < parts.count - 1
            link_to name, "/" + parts[0..index].join("/")
          else
            name
          end
        end
      end

    end
  end
end
