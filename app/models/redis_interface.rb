class RedisInterface
  attr_accessor :redis,:prefix
  TIMEOUT_SECONDS = 1.week
 
  def initialize(prefix: "")
    @prefix = prefix
    connect
  end

  # Sets value for given key
  def set(key, value, expire = true)
    redis.set("#{@prefix}#{key}", value)
    if expire
      redis.expire("#{@prefix}#{key}", TIMEOUT_SECONDS)
    end
  end

  # Returns value for given key
  def get(key)
    redis.get("#{@prefix}#{key}")
  end

  # Increment key
  def incr(key)
    redis.incr("#{@prefix}#{key}")
  end

  # Decrement key
  def decr(key)
    redis.decr("#{@prefix}#{key}")
  end

  # Returns keys
  def keys(query)
    redis.keys(query)
  end

  # Delete specific key
  def del(key)
    redis.del("#{@prefix}#{key}")
  end

  # Drop all db contents
  def flushdb
    redis.flushdb
  end

  # Encapsulate statements within a transaction
  def transaction
    redis.multi
    yield
    redis.exec
  end

  # Stop and remove transaction
  def discard
    redis.discard
  end

  # Returns a redis connection
  def connect
    $redis.client.reconnect
    @redis = $redis
  end
end
