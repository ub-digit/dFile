require 'yaml'

# Load Redis config
REDIS_CONFIG = YAML.load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
default_config = REDIS_CONFIG[:default].symbolize_keys
config = default_config.merge(REDIS_CONFIG[Rails.env.to_sym].symbolize_keys) if REDIS_CONFIG[Rails.env.to_sym]

$redis = Redis.new(config)

# To clear out the db before each test
$redis.flushdb if Rails.env == "test"


