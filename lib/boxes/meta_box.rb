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
  	
    def html_options=(p)
      write_attribute(:html_options, json_parse(p))
    end
    
    def wopts=(p)
      if p.is_a?(Hash) && !p.blank?
        h = {}
        p.each do |k, v|
          h[k.to_sym] = json_parse(v)
        end
        write_attribute(:wopts, h)
      else
        write_attribute(:wopts, nil)
      end
    end

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
        add_widget_error(:new, e.to_s)
    	  ::Rails.logger.debug("Could not instanciate configuration widget: #{e}")
    		return nil
    	end
    	w.respond_to?(:box_configure_form) ? w : nil
    end
	
  	def widget(controller, name=nil, state=nil, override=nil)
  	  return nil if wclass.blank?
  	  if wname.blank?
  	    add_widget_error(:wname, "Missing instance name.")
  	    return nil
	    end
	    klass = widget_class
	    return if klass.nil?
  	  # check contructor params
  	  begin
  	    wstate = "display" if wstate.blank?
  	    w = klass.new(controller, name.blank? ? wname : name, state.blank? ? wstate : state, override.blank? ? wopts || {} : override)
  	  rescue Exception => e
  	    add_widget_error(:new, e.to_s)
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


    def widget_errors
      @werrors.blank? ? nil : @werrors.dup
    end
  
  
    private
    def widget_class
  	  return nil if wclass.blank?
  		# check widget class
  		klass = nil
  	  begin
    		klass = eval wclass
  		rescue Exception => e
  		  add_widget_error(:wclass, e.to_s)
  		  ::Rails.logger.debug("Could not eval widget class: #{wclass}: #{e}")
  		  return nil
  	  end
  	  klass
	  end
  	
    def json_parse(value=nil)
      return nil if value.blank?
      if value.is_a?(String)
        begin
          value = JSON.parse(value)
        rescue Exception => e
          # ::Rails.logger.debug("Could not parse #{value} as JSON: #{e}")
          return value
        end
      end
      value
    end
    
    def add_widget_error(attrib, message)
      @werrors ||= []
      @werrors << [attrib, message]
    end
    	
  end
end