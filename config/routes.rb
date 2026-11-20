Rails.application.routes.draw do
  scope controller: :items, defaults: { format: :json } do
    get '/checksum', action: :checksum
    get '/move_folder_ind', action: :move_folder_ind
    get '/copy_folder_ind', action: :copy_folder_ind
    get '/move_folder', action: :move_folder
    post '/create_file', action: :create_file
    get '/copy_file', action: :copy_file
    get '/copy_files', action: :copy_files
    get '/move_files', action: :move_files
    get '/move_file', action: :move_file
    get '/list_files', action: :list_files
    get '/combine_pdf_files', action: :combine_pdf_files
    get '/file_count', action: :file_count
    get '/get_image', action: :get_image
    get '/copy_and_convert_images', action: :copy_and_convert_images
    get '/copy_and_convert_image', action: :copy_and_convert_image
    get '/download_file', action: :download_file, defaults: { format: :file }
    get '/move_to_trash', action: :move_to_trash
    get '/thumbnail', action: :thumbnail
    get '/rename_files', action: :rename_files
    get '/convert_images', action: :convert_images
    get '/delete_folder', action: :delete_files
    get '/delete_files', action: :delete_files
    get '/delete_file', action: :delete_file
    get '/get_file_metadata_info', action: :get_file_metadata_info
  end
end
