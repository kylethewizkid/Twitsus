Rails.application.routes.draw do
  root 'homepage#index'
  match 'homepage/kill_clients' => 'homepage#kill_clients', :via => [:post]
  match 'homepage/change_bounds' => 'homepage#change_bounds', :via => [:post]
end