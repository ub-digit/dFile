require 'yaml'
require "erb"

redis_config_file =  'config/redis.yml'
redis_yaml = Pathname.new("#{Rails.root}/#{redis_config_file}")
redis_config = YAML.load(ERB.new(redis_yaml.read).result(binding))
REDIS_CONFIG = redis_config.symbolize_keys
reddis_default_config = REDIS_CONFIG[:default].symbolize_keys
config = reddis_default_config.merge(REDIS_CONFIG[Rails.env.to_sym].symbolize_keys) if REDIS_CONFIG[Rails.env.to_sym]
$redis = Redis.new(config)
# To clear out the db before each test
$redis.flushdb if Rails.env == "test"


filevault_config_file = 'config/filevault.yml'
filevault_yaml = Pathname.new("#{Rails.root}/#{filevault_config_file}")
filevault_config = YAML.load(ERB.new(filevault_yaml.read).result(binding))
FILEVAULT_CONFIG = filevault_config.symbolize_keys
filevault_default_config = FILEVAULT_CONFIG[:dfile_paths]
Rails.configuration.dfile_paths = filevault_default_config