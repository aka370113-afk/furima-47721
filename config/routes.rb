Rails.application.routes.draw do
  devise_for :users
root to: "items#index"

# itemsの中にordersをネストさせる
  resources :items do
    resources :orders, only: [:index, :create]
  end
end
