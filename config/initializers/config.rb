Rails.application.config.dfile_paths = {
  "PROCESSING" => ENV['DFILE_PROCESSING_PATH'],
  "TEST_PROCESSING" => ENV['DFILE_TEST_PROCESSING_PATH'],
  "PACKAGING" => ENV['DFILE_PACKAGING_PATH'],
  "STORE" => ENV['DFILE_STORE_PATH'],
  "TRASH" => ENV['DFILE_TRASH_PATH'],
  "CONFIGURATION" => ENV['DFILE_CONFIGURATION_PATH'],
 # "GUPEA" => "/var/tmp/gupea/dflow/new/",

 # "OCR-TODO" => "/var/tmp/dflow/dig-ocr/digibot/ocr_todo/",
#  "OCR-DONE" => "/var/tmp/dflow/dig-ocr/digibot/ocr_done/",
#  "DIG-ARK" => "/var/tmp/dflow/dig-ark/",
#  "IDUN" => "/var/tmp/dflow/bilder/digitaliseringsprojekt/idun_nya/gamla_idun/",
#  "REPACKAGING" => "/var/tmp/dflow/bilder/dflow/REPACKAGING/",
#  "TEST_PROCESSING" => "/var/tmp/dflow/dig-nas/test_processing",
#  "TEST_PACKAGING" => "/var/tmp/dflow/bilder/dflow/TEST_PACKAGING/",
#  "TEST_STORE" => "/var/tmp/dflow/bilder/dflow/TEST_STORE/",
#  "IMPORT" => "/var/tmp/dflow/bilder/dflow/IMPORT/",
#  "LEVERANS" => "/var/tmp/dflow/bilder/digitaliseringsprojekt/leverans/",
#  "LITTERATURBANKEN" => "/var/tmp/dflow/bilder/digitaliseringsprojekt/leverans/litteraturbanken/",
#  "SKONLITT" => "/var/tmp/dflow/bilder/ftp/upload/",
#  "LABAN" => "/var/tmp/dflow/bilder/",
#  "LASSTOD" => "/var/tmp/dflow/bilder/digitaliseringsprojekt/leverans/lasstod/"
}

Rails.application.config.api_key =  ENV['API_KEY']