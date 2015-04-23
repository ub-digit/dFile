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
end
