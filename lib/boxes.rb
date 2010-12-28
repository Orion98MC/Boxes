require 'boxes/core'
require 'boxes/box'
require 'boxes/controller'

module Boxes
end

ActionController::Base.extend(Boxes::Controller::ClassMethods)
ActionView::Base.send(:include, Boxes::ViewHelpers)
