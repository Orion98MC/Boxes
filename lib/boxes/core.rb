module Boxes
  # append the boxes views path to the cells view paths
  Cell::Base.append_view_path([File.dirname(__FILE__), '..', '..', 'app', 'cells'].join('/'))
  
  class << self
    attr_accessor :widgets_class_names    
    attr_writer :model_class
    def meta_model
      @model_class ||= "Boxes::MetaBox"
      @model_class.is_a?(String) ? eval(@model_class) : @model_class 
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
				next if not box_meta.published?
				
				box = Boxes::Box.new(controller, parent_box.blank? ? "box-#{index.to_s}" : "#{parent_box.name}-#{index}")
				box_meta.configurable = true
				box.meta = box_meta
				
				if not controller.class.boxes_blocks.blank?
				  controller.class.boxes_blocks.each do |block|
				    block.call(box, controller)
			    end
				end
				
				::Rails.logger.debug("New box: #{box.name}\n")
				
				widget = box_meta.widget(controller)
				if widget
  				box.widget = widget
  				box << widget
			  end
				root << box
				
				build_boxes_tree(box, controller, boxes_meta, box)
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
