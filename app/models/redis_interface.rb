class RedisInterface
  attr_accessor :redis
 
  def initialize
    connect
  end

  # Sets value for given key
  def set(key, value)
    redis.set(key, value)
  end

  # Returns value for given key
  def get(key)
    redis.get(key)
  end

  # Increment key
  def incr(key)
    redis.incr(key)
  end

  # Decrement key
  def decr(key)
    redis.decr(key)
  end

  # Returns keys
  def keys(query)
    redis.keys(query)
  end

  # Delete specific key
  def del(key)
    redis.del(key)
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
