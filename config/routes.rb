Rails.application.routes.draw do

  controller :items, :defaults => {:format => :json} do
    get '/items/checksum'
    get '/items/copy_file', to: 'items#copy_file'
    get '/items/copy_files', to: 'items#copy_files'
    get '/items/move_files', to: 'items#move_files'
    get '/items/move_file', to: 'items#move_file'
    get '/items/list_files', to: 'items#list_files'
    get '/items/combine_pdf_files', to: 'items#combine_pdf_files'
    get '/items/file_count', to: 'items#file_count'
    get '/items/get_image', to: 'items#get_image'
    get '/items/copy_and_convert_images', to: 'items#copy_and_convert_images'
    get '/items/copy_and_convert_image', to: 'items#copy_and_convert_image'
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
