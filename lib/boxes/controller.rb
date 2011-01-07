module Boxes
  module Controller

    module ClassMethods      
      attr_accessor :boxes_options, :boxes_blocks
    
      # add boxes to a ActiveController
      # ex:
      #   has_boxes :except => [:foo, :bar]
      # ex with a block:
      #   has_boxes :only => [:home, :contact] do |box, controller|
      #      box.meta.configurable = false if not @current_user.is_admin?
      #   end
      def has_boxes(options = {}, &block)
        # include box controller actions
        self.send(:include, Boxes::Controller::Actions)
        
        # save options and block
        self.boxes_options = options
        raise "has_boxes: :except and :only are mutualy exclusive" if options.has_key?(:except) && options.has_key?(:only)
        
        if block_given?
          self.boxes_blocks ||= []
          self.boxes_blocks << block 
        end
        
        has_widgets do |root|
          # filter new/remove box calls
          if not [:new_box, :remove_box].include?(action_name.to_sym)
          
            # get back the options
            options = self.class.boxes_options
          
            # filter options
            unless (options[:except] && [options[:except]].flatten.include?(action_name.to_sym)) ||
                   (options[:only] && ![options[:only]].flatten.include?(action_name.to_sym))
          
              # record the address
              session[:boxes_address] = "#{controller_name}##{action_name}" if not action_name.match(/#{apotomo_event_path(:controller => controller_name).split('/').last}/)
              return if session[:boxes_address].blank? # safe guard, in case of a server restart and the client trying to connect with an ajax call
          
              # Set the @_boxes ivar (used to store stylesheets/javascripts to include)
              self.instance_variable_set("@_boxes_content", {:stylesheets => [], :javascripts => []})
              
              # build widget tree for the address
              Boxes::Core.build_boxes_tree(root, self, Boxes.meta_model.at_address(session[:boxes_address]))
            else
              session[:boxes_address] = nil
            end
            
          end 
          
        end # has_widgets
      end # has_boxes
      
    end
    
    module InstanceMethods
      # returns the current recorded boxes address
      def boxes_address
        session[:boxes_address]
      end
      
      def boxes_javascripts
        @_boxes_content[:javascripts]
      end
      
      def boxes_stylesheets
        @_boxes_content[:stylesheets]
      end
      
      
    end
        
    module Actions
      def new_box
        raise "has_boxes: not a managed action" if session[:boxes_address].nil?
        box = MetaBox.new(:address => session[:boxes_address], :parent_id => params[:meta_id])
        box.save
        redirect_to :action => session[:boxes_address].split('#').last.to_sym
      end

      def remove_box
        raise "has_boxes: not a managed action" if session[:boxes_address].nil?
        box = MetaBox.find(params[:meta_id])
        box.destroy
        redirect_to :action => session[:boxes_address].split('#').last.to_sym
      end
    end
    
  end
end