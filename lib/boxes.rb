require 'boxes/view_helpers'
require 'boxes/core'
require 'boxes/box'
require 'boxes/controller'

module Boxes
end

ActionController::Base.extend(Boxes::Controller::ClassMethods)
ActionController::Base.send(:include, Boxes::Controller::InstanceMethods)
ActionView::Base.send(:include, Boxes::ViewHelpers)
