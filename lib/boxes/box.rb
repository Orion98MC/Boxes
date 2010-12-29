module Boxes
  
  class Box < Apotomo::Widget
  	helper Boxes::ViewHelpers

  	attr_accessor :meta, :widget

  	def initialize(controller, name)
  		super(controller, name, :display)
  		
  		# prevent propagation of some event
  		on :configure do |event| event.stop!; end
  		on :save do |event| event.stop!; end
      on :display do |event| event.stop!; end
      on :update_configure do |event| event.stop!; end
  	end

    responds_to_event :display, :with => :reload
    def reload
      replace :state => :display
	  end
  	
  	def display
      render
  	end

    responds_to_event :configure, :with => :configure
  	def configure
  	  @should_suppress_js ||= false
  	  c = meta.configure_widget(parent_controller)
  	  if not c.nil?
  	    @configurable = true
  	    reset_widget(c)
	    end
      replace
  	end
  	
  	responds_to_event :update_configure, :with => :update_configure
  	def update_configure
  	  meta.wclass = param(:wclass) if param(:wclass)
  	  @should_suppress_js = true
  	  render :state => :configure
	  end
  	  	
  	responds_to_event :save, :with => :save
  	def save
  	  configurable = meta.configurable? # save the configurable state
  		meta = Boxes.meta_model.find(param(:meta_id))
  		::Rails.logger.debug "MetaBox: #{meta}"
  		unless meta.blank?
        if meta.update_attributes(param(:meta))
  		    self.meta = meta
  		    self.meta.configurable = configurable
		    end
        reset_widget(meta.widget(parent_controller))
		  end
  		replace :state => :display
  	end
  	 
  	private 	
  	def reset_widget(widget)
  	  @widget.removeFromParent! if not @widget.blank?
  	  @widget = widget
  	  self << @widget if not @widget.blank?
  	end
  	
  end
  
end