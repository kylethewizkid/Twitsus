Rails.application.routes.draw do
  root 'twitter_api#index'
  match 'twitter_api/kill_clients' => 'twitter_api#kill_clients', :via => [:post]
end