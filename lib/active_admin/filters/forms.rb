module ActiveAdmin
  module Filters
    # This form builder defines methods to build filter forms such
    # as the one found in the sidebar of the index page of a standard resource.
    class FormBuilder < ::ActiveAdmin::FormBuilder
      include ::ActiveAdmin::Filters::FormtasticAddons
      self.input_namespaces = [::Object, ::ActiveAdmin::Inputs::Filters, ::ActiveAdmin::Inputs, ::Formtastic::Inputs]

      # TODO: remove input class finders after formtastic 4 (where it will be default)
      self.input_class_finder = ::Formtastic::InputClassFinder

      def filter(method, options = {})
        if method.present? && options[:as] ||= default_input_type(method)
          template.concat input(method, options)
        end
      end

      protected

      # Returns the default filter type for a given attribute. If you want
      # to use a custom search method, you have to specify the type yourself.
      def default_input_type(method, options = {})
        if method =~ /_(eq|equals|cont|contains|start|starts_with|end|ends_with)\z/
          :string
        elsif klass._ransackers.key?(method.to_s)
          klass._ransackers[method.to_s].type
        elsif reflection_for(method) || polymorphic_foreign_type?(method)
          :select
        elsif column = column_for(method)
          case column.type
          when :date, :datetime
            :date_range
          when :string, :text
            :string
          when :integer, :float, :decimal
            :numeric
          when :boolean
            :boolean
          end
        end
      end
    end

    # This module is included into the view
    module ViewHelper

      # Helper method to render a filter form
      def active_admin_filters_form_for(search, filters, options = {})
        defaults = { builder: ActiveAdmin::Filters::FormBuilder,
                     url: collection_path,
                     html: { class: "filter_form" } }
        required = { html: { method: :get },
                     as: :q }
        options = defaults.deep_merge(options).deep_merge(required)

        form_for search, options do |f|
          filter_fields = content_tag :div, class: "filter_form_fields row row-cols-1 row-cols-lg-2 row-cols-xxl-3" do
            filters.each do |attribute, opts|
              next if opts.key?(:if) && !call_method_or_proc_on(self, opts[:if])
              next if opts.key?(:unless) && call_method_or_proc_on(self, opts[:unless])

              filter_opts = opts.except(:if, :unless)
              filter_opts[:input_html] = instance_exec(&filter_opts[:input_html]) if filter_opts[:input_html].is_a?(Proc)

              f.filter attribute, filter_opts
            end
          end
          f.template.concat filter_fields

          clearfix = content_tag :div, class: 'clearfix' do
          end
          f.template.concat clearfix

          buttons = content_tag :div, class: "buttons" do
            f.submit(I18n.t("active_admin.filters.buttons.filter"), class: 'btn btn-success me-1') +
              link_to(I18n.t("active_admin.filters.buttons.clear"), "#", class: "clear_filters_btn btn btn-danger") +
              hidden_field_tags_for(params, except: except_hidden_fields)
          end
          f.template.concat buttons
        end
      end

      private

      def except_hidden_fields
        [:q, :page]
      end
    end

  end
end
