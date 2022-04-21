module ActiveAdmin
  module Views

    class ActionItems < ActiveAdmin::Component

      def build(action_items)
        action_items.each do |action_item|
          span class: action_item.html_class do
            html = instance_exec(&action_item.block)
            if html.index('btn').nil?
              class_pos = html[0..(html.index('>') || -1)].index('class=')
              if class_pos.nil?
                pos = html.index('>') || html.index('/>')
                html.insert(pos, ' class="btn btn-secondary" ')
              else
                html.insert(class_pos + html[(class_pos + 7)..-1].index('"'), ' btn btn-secondary ')
              end
            end
            html
          end
        end
      end

    end

  end
end
