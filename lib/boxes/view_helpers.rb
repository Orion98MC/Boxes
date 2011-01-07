module Boxes
  module ViewHelpers
    
    def box_div(options={:class => 'box'}, &block)
      options[:class] = options[:class] + " configurable" if @cell.meta.configurable?
      html_options = @cell.meta.html_options if @cell.meta.html_options.is_a?(Hash)
      options.merge!(html_options || {})
      widget_div(options, &block)
    end
        
    def box_name
      @cell.name
    end
    
    #<------
    # These 2 helper don't work yet... not using them until it's okay...
    # Ask Nick about the locals (rendered_children) not being available to the helpers (box_widget and boxes)
    def box_widget
      return if @widget.blank?
      rendered_children[@widget.name]
    end
    
    def boxes
      return if not @cell.meta.children?
      #... TODO: get rid of render_boxes
    end
    #------>
    
    # render root boxes.
    # boxes that have no parent
    # Only in the controller action's view (not in the widget view)!!!
    def render_boxes
      content = []
      controller.apotomo_root.children.each do |widget|
        content << render_widget(widget) if widget.is_a?(Boxes::Box)
      end
      content.join.html_safe
    end
    
    #
    def boxes_javascript_include_tag
      boxes_content = controller.instance_variable_get("@_boxes_content") || {}
      js = boxes_content[:javascripts] || []
      (js.flatten.uniq||[]).collect{|js| javascript_include_tag(js)}.join("\n").html_safe
    end

    #
    def boxes_stylesheet_link_tag
      boxes_content = controller.instance_variable_get("@_boxes_content") || {}
      st = boxes_content[:stylesheets] || []
      # by default we include the boxes.css 
      st << "boxes" 
      (st.flatten.uniq||[]).collect{|st| stylesheet_link_tag(st)}.join("\n").html_safe
    end
    
    # Add a brother box link
    def link_to_add_sibling_box(name="Add a box", options={})
      return if not Boxes.allows_creation?
      if defined? @cell
        if @cell.is_a? Boxes::Box
          # TODO: implement a Boxes::Box method to handle it in ajax
          link_to name, new_box_path(
              :controller => @cell.parent_controller.controller_name, 
              :meta_id => @cell.meta.id
            ), options
        end
      else
        link_to name, new_box_path(:controller => controller.controller_name), options
      end
    end
    
    # remove a box link
    def link_to_remove_box(name='Remove box', options={:class => "remove_box"})
      return if not defined? @cell
      # TODO: implement a Boxes::Box method to handle it in ajax
      link_to name, remove_box_path(:controller => @cell.parent_controller.controller_name, :meta_id => @cell.meta.id), options.merge(:method => :put)
    end
    
    # yield a block only when the MetaBox is configurable
    # usefull to determin who can access the configuration of boxes.
    # Ex:
    # class DashboardController < ApplicationController
    #   include Apotomo::Rails::ControllerMethods
    # 
    #   has_boxes do |box|
    #     box.meta.configurable = false if not @current_user.is_admin?
    #   end
    def boxes_configuration_block(&block)
      return if not @cell.is_a?(Boxes::Box)
      return if not @cell.meta.configurable?
      yield
    end
    
  end
end