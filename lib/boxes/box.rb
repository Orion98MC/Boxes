module Boxes
  
  class Box < Apotomo::Widget
    
    responds_to_event :save, :with => :save
  	responds_to_event :configure, :with => :configure
  	responds_to_event :display, :with => :reload
  	
  	helper Boxes::ViewHelpers

  	attr_accessor :meta, :widget

  	def initialize(controller, name)
  		super(controller, name, :display)
  		
  		# prevent propagation of some event
  		on :configure do |event| event.stop!; end
  		on :save do |event| event.stop!; end
      on :display do |event| event.stop!; end
  	end

  	def display
      render
  	end

  	def configure
  		replace
  	end
  	
  	def reload
      replace :state => :display
	  end

  	def save
  	  configurable = meta.configurable?
  		meta = Boxes.meta_model.find(param(:meta_id))
  		::Rails.logger.debug "MetaBox: #{meta}"
  		unless meta.blank?
        if meta.update_attributes(param(:meta))
  		    self.meta = meta
  		    self.meta.configurable = configurable
		    end
		    ::Rails.logger.debug "meta: #{param(:meta).to_json}"
        self.reset_widget(meta.widget(parent_controller))
		  end
		  
  		replace :state => :display
  	end
  	  	
  	def reset_widget(widget)
  	  @widget.removeFromParent! if not @widget.blank?
  	  return if widget.blank?
  	  @widget = widget
  	  if not @widget.blank?
    	  self << @widget
  	  end
  	end
  	
  end
  
end