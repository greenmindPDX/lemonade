require 'redis'
# set of methods to get/set hashes at unique keys
module Zaphod
  class Keystorage
    attr_accessor :redis, :namespace

    # Connect to  Redis server
    def self.redis
      unless @redis
        # @todo use enviro vars
        settings = {}
        settings[:host] = ENV['REDIS_HOST']
        settings[:port] = ENV['REDIS_PORT']
        #password = cfg.redis_pwd
        #settings[:password] = password unless password.nil?
        @redis = Redis.new(settings)
      end
      @redis
    end

    # Add a key with a set of values
    #
    def self.add(key, values = {})
      redis.hmset(formatted_key(key), values.to_a.flatten)
    end

    # Return all of the values stored in Redis contained in the
    # namespace of this class
    def self.all(key)
      redis.hgetall(formatted_key(key))
    end

    # Return all the values of a hash if key exists
    #
    def self.get(key, field)
      redis.hget(formatted_key(key), field)
    end

    # Return list of values of a hash, without its keys
    #
    def self.getval(key)
      redis.hvals(formatted_key(key))
    end

    def self.namespace(namespace)
      @namespace = namespace
    end


    def self.formatted_key(key)
      "#{@namespace}:#{key}"
    end

  end
end
