Rails.application.routes.draw do

  controller :items, :defaults => {:format => :json} do
    get '/checksum', to: 'items#checksum'
    get '/move_folder_ind', to: 'items#move_folder_ind'
    get '/copy_folder_ind', to: 'items#copy_folder_ind'
    get '/move_folder', to: 'items#move_folder'
    post '/create_file', to: 'items#create_file'
    get '/copy_file', to: 'items#copy_file'
    get '/copy_files', to: 'items#copy_files'
    get '/move_files', to: 'items#move_files'
    get '/move_file', to: 'items#move_file'
    get '/list_files', to: 'items#list_files'
    get '/combine_pdf_files', to: 'items#combine_pdf_files'
    get '/file_count', to: 'items#file_count'
    get '/get_image', to: 'items#get_image'
    get '/copy_and_convert_images', to: 'items#copy_and_convert_images'
    get '/copy_and_convert_image', to: 'items#copy_and_convert_image'
    get '/download_file', to: 'items#download_file', defaults: {format: :file}
    get 'move_to_trash', to: 'items#move_to_trash'
    get 'thumbnail', to: 'items#thumbnail'
  end
end
