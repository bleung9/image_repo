Rails.application.routes.draw do
  resources :images, only: [:index, :show, :new, :create]
  post 'similar_images', to: 'images#get_similar_images', as: :similar_images
end
