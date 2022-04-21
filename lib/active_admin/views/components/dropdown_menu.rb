module ActiveAdmin
  module Views

    # Action List - A button with a drop down menu of links
    #
    # Creating a new action list:
    #
    #     dropdown_menu "Administration" do
    #       item "Edit Details", edit_details_path
    #       item "Edit My Account", edit_my_account_path
    #     end
    #
    # This will create a button with the label "Administration" and
    # a drop down once clicked with 2 options.
    #
    class DropdownMenu < ActiveAdmin::Component
      builder_method :dropdown_menu

      # Build a new action list
      #
      # @param [String] name  The name to display in the button
      #
      # @param [Hash] options A set of options that get passed along to
      #                       to the parent dom element.
      def build(name, options = {})
        options = options.dup

        menu_options = options.delete(:menu) || {}
        menu_options[:id] = "#{options[:id]}-dropdown"

        button_options = options.delete(:button) || {}
        button_options.delete(:id)
        button_options[:href] = "##{options[:id]}-menu"
        button_options[:'data-bs-target'] = "##{options[:id]}-dropdown"

        @button = build_button(name, button_options)
        @menu = build_menu(menu_options)

        super(options)
      end

      def item(*args, **kwargs)
        within @menu do
          li link_to(*args, **kwargs), class: 'dropdown-item'
        end
      end

      private

      def build_button(name, button_options)
        button_options[:class] ||= ""
        button_options[:class] << " dropdown-toggle"

        button_options[:role] = 'button'
        button_options[:'data-bs-toggle'] = 'dropdown'

        button_options[:href] = "#"

        a name, button_options
      end

      def build_menu(options)
        options[:class] ||= ""
        options[:class] << " dropdown-menu dropdown-menu-end"
        # options[:class] << " dropdown_menu_list dropdown-menu" # keep dropdown_menu_list for js compatibility but also add Bootstrap dropdown-menu

        menu_list = nil

        # div id: options[:id] do
        #   menu_list = ul(options.except(:id))
        # end
        menu_list = ul(options)

        menu_list
      end

    end

  end
end
