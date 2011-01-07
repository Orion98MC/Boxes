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
  	  render :state => :configure
	  end
  	  	
  	responds_to_event :save, :with => :save
  	def save
  	  configurable = meta.configurable? # save the configurable state
  		meta = Boxes.meta_model.find(param(:meta_id))
  		::Rails.logger.debug "MetaBox: #{meta}"
  		unless meta.blank?
  		  published = meta.published?
  		  
        if meta.update_attributes(param(:meta))
  		    self.meta = meta
  		    self.meta.configurable = configurable
  		    # The widget tree is already built so ...
  		    if not self.meta.published?
  		      # remove children
    		    self.children.reject{|w|w == @widget}.each{|w|w.removeFromParent!} 
    		    @widget.removeFromParent! if not @widget.blank?
  		    else
  		      # we should add the children by hand
  		      Boxes::Core.build_boxes_tree(self, parent_controller, Boxes.meta_model.at_address(session[:boxes_address]), self) if not published
		      end
		    end
        reset_widget(meta.published? ? meta.widget(parent_controller) : nil)
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