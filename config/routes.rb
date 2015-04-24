Rails.application.routes.draw do

  controller :items, :defaults => {:format => :json} do
    get '/checksum', to: 'items#checksum'
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
  end
end
