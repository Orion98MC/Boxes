module Boxes
  class MetaBox < ActiveRecord::Base
    
  	belongs_to :parent, :class_name => self.to_s
  	serialize :wparams
  	serialize :html_options
  	before_destroy :remove_descendants
	
  	attr_accessor :configurable
	
  	scope :at_address, lambda{|address| where(:address => address)}
		
  	def published?; published == true; end
  	def configurable?; configurable == true; end
		
  	def children
  		self.class.where(:parent_id => self.id)
  	end
	
  	def children?
  		children.count > 0
  	end
	
  	def widget(controller)
  		return nil if wclass.blank?
		
  		# check widget class
  		klass = nil
  	  begin
    		klass = eval wclass
  		rescue Exception => e
  		  ::Rails.logger.debug("Could not eval widget class: #{wclass}: #{e}")
  		  return nil
  	  end
	  
  	  # check contructor params
  	  begin
  	    w = klass.new(controller, *wparams)
  	  rescue Exception => e
  	    ::Rails.logger.debug("Could not instanciate widget with params(#{wparams.to_json}): #{e}")
  		  return nil
  	  end
	  
      # # try render ... in case a state might throw an error
      # begin
      #       test_controller = controller.clone
      #       test_widget = klass.new(test_controller, *wparams)
      #       test_controller.render_widget(test_widget)
      # rescue Exception => e
      #   ::Rails.logger.debug("Could not render widget: #{e}")
      #   return nil
      # end
	  
  	  ::Rails.logger.debug("Created widget: #{klass}.new(#{controller.controller_name}, *#{wparams.to_json})")
  		w
  	end
		  
    def wparams=(p)
      json_string_to_attribute(:wparams, p)
    end
  
    def html_options=(p)
      json_string_to_attribute(:html_options, p)
    end

  	def descendants
  	  c = children
  	  return nil if c.blank?
  	  d = []
  	  c.each do |child|
  	    d << child
  	    d << child.descendants
      end
      d.flatten!
      d - [nil] if not d.blank?
    end
  
    def remove_descendants
      d = descendants
      return if d.blank?
      d.each do |c|
        c.destroy
      end
    end
  
    private
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