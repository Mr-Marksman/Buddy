Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root "posts#index"

  devise_for :users
  patch '/users/update_my_posts', to: 'users#update_my_posts', as: :update_my_posts_user

  resources :posts, except: %i[show] do
    resources :pictures, only: %i[create destroy]
    resources :comments, only: %i[create destroy update]
    resources :subscriptions, only: %i[create destroy]
    post :show, on: :member
  end

  resources :users, only: %i[show] do
    resources :friendships, only: %i[create destroy]
  end
end
