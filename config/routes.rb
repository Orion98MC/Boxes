Rails.application.routes.draw do
  match ":controller/new_box", :to => "#new_box", :as => "new_box"
  match ":controller/remove_box", :to => "#remove_box", :as => "remove_box"
end