module Boxes
  class MetaBox < ActiveRecord::Base
    acts_as_list :scope => :parent
  	belongs_to :parent, :class_name => self.to_s
  	serialize :wopts
  	serialize :html_options
  	before_destroy :remove_descendants
	
  	attr_accessor :configurable
	
  	scope :at_address, lambda{|address| where(:address => address)}
		
  	def published?; published == true; end
  	def configurable?; configurable == true; end
  	
  	def children; self.class.where(:parent_id => self.id); end
  	def children?; children.count > 0; end
  	
    def wopts=(p); json_string_to_attribute(:wopts, p); end
    def html_options=(p); json_string_to_attribute(:html_options, p); end

  	def descendants
  	  d = []
  	  children.each do |child|
  	    d << child
  	    d << child.descendants
      end
      d.flatten - [nil]
    end
  
    def remove_descendants; descendants.each {|c| c.destroy}; end
  		  
	  # Return the widget in :box_configure_form start state if it exists
    def configure_widget(controller)
      klass = widget_class
      return nil if klass.nil?
      begin
        w = klass.new(controller, "#{id}-configure", :box_configure_form, wopts || {})
      rescue Exception => e
    	  ::Rails.logger.debug("Could not instanciate configuration widget: #{e}")
    		return nil
    	end
    	w.respond_to?(:box_configure_form) ? w : nil
    end
	
  	def widget(controller)
  		return nil if wclass.blank? || wname.blank? || wstate.blank?
	    klass = widget_class
	    return if klass.nil?
  	  # check contructor params
  	  begin
  	    w = klass.new(controller, wname, wstate, wopts || {})
  	  rescue Exception => e
  	    ::Rails.logger.debug("Could not instanciate widget with name: #{wname}, state: #{wstate}, options: #{wopts.to_json} => #{e}")
  		  return nil
  	  end
	  
	    return nil if not w.respond_to?(wstate.to_sym)
	    
      # # try render ... in case a state might throw an error
      # begin
      #       test_controller = controller.clone
      #       test_widget = klass.new(test_controller, *wparams)
      #       test_controller.render_widget(test_widget)
      # rescue Exception => e
      #   ::Rails.logger.debug("Could not render widget: #{e}")
      #   return nil
      # end
	  
  	  ::Rails.logger.debug("Created widget: #{klass}.new(#{controller.controller_name}, #{wname}, #{wstate}, #{wopts.to_json})")
  		w
  	end
  
  
    private
    def widget_class
  	  return nil if wclass.blank?
  		# check widget class
  		klass = nil
  	  begin
    		klass = eval wclass
  		rescue Exception => e
  		  ::Rails.logger.debug("Could not eval widget class: #{wclass}: #{e}")
  		  return nil
  	  end
  	  klass
	  end
  	
    def json_string_to_attribute(attribute, value)
      if value.is_a?(String) && !value.blank?
        begin
          value = JSON.parse(value)
        rescue Exception => e
          ::Rails.logger.debug("Could not parse #{attribute} as JSON: #{e}")
          return
        end
      end
      write_attribute(attribute.to_sym, value)
    end
  	
  end
end