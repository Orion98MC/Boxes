module Boxes
  # append the boxes views path to the cells view paths
  Cell::Base.append_view_path([File.dirname(__FILE__), '..', '..', 'app', 'cells'].join('/'))
  
  class << self
    attr_writer :allows_creation
    def allows_creation?
      @allows_creation = true if @allows_creation.nil?
      @allows_creation
    end
    
    attr_writer :configurable
    def configurable?
      @configurable = true if @configurable.nil?
      @configurable
    end
    
    attr_accessor :widgets_class_names    
    
    attr_writer :model_class
    def meta_model
      @model_class ||= "Boxes::MetaBox"
      mc = @model_class.is_a?(String) ? eval(@model_class) : @model_class 
      ::Rails.logger.debug "Model class: #{mc}"
      mc
    end
    
    # Configure boxes
    # ex:
    # Boxes.setup do |config|
    #   config.widgets_class_names = ["TwitterWidget"]
    #   config.model_class = "MetaBox"
    # end
    def setup
      yield self
    end
    
  end 
  
  
  class Core
    
    # :nodoc:
    def self.build_boxes_tree(root, controller, boxes_meta, parent_box=nil)
			return if boxes_meta.blank?
			
			boxes_meta.reject{|meta| meta.parent_id != (parent_box.nil? ? nil : parent_box.meta.id)}.each_with_index do |box_meta, index|		    				
				box = Boxes::Box.new(controller, parent_box.blank? ? "box-#{index.to_s}" : "#{parent_box.name}-#{index}")
				box_meta.configurable = Boxes.configurable?
				box.meta = box_meta
				
				if not controller.class.boxes_blocks.blank?
				  controller.class.boxes_blocks.each do |block|
				    case block.arity
				    when 1
				      block.call(box)
			      when 2
			        block.call(box, controller)
		        else
		          block.call
				    end
			    end
				end
				
				::Rails.logger.debug("New box: #{box.name}\n")
				root << box
				
				if box_meta.published?
				  widget = box_meta.widget(controller)
  				if not widget.nil?
    				box.widget = widget
    				# javascripts and stylesheets
    				if widget.class.respond_to?(:javascripts)
    				  _boxes = controller.instance_variable_get("@_boxes_content")
    				  _boxes[:javascripts] << widget.class.javascripts
      				controller.instance_variable_set("@_boxes_content", _boxes)
      				::Rails.logger.debug("Added javascripts: #{_boxes.to_json}")
    				end
    				if widget.class.respond_to?(:stylesheets)
    				  _boxes = controller.instance_variable_get("@_boxes_content")
    				  _boxes[:stylesheets] << widget.class.stylesheets
      				controller.instance_variable_set("@_boxes_content", _boxes)
    				end
    				box << widget
  			  end
  				build_boxes_tree(box, controller, boxes_meta, box)
				end
			
			end
		end
		
		def self.attach_event_responders(*)
		end 
  end # Core        
  
end

module Onfire
  alias :process_event_OLD :process_event
  def process_event(event)
    puts "#{self.name} processing event: #{event.type}"
    process_event_OLD(event)
  end
  
end
