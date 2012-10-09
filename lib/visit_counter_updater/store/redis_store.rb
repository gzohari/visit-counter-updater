require "redis"

module VisitCounter
  class Store
    class RedisStore < VisitCounter::Store::AbstractStore
      class << self
        ## adding keys to sorted sets, to allow searching by timstamp(score).
        ## subsequent hits to the same key will only update the timestamp (and won't duplicate).
        def incr(key, timestamp, set_name)
          redis.zadd(set_name, timestamp, key)
          redis.incr(key).to_i
        end

        def del(key)
          redis.del(key)
        end

        def mget(keys)
          redis.mget(*keys).map(&:to_i)
        end

        def mnullify(keys)
          keys_with_0 = keys.flat_map {|k| [k,"0"]}
          redis.mset(*keys_with_0)
        end

        ## Usage: to get all post#num_reads counters in the last hour, do:
        ## redis.zrangebyscore("visit-counter::Post::num_reads", (Time.now - 3600).to_i, Time.now.to_i)
        def get_all_by_range(sorted_set_key, min, max)
          redis.zrangebyscore(sorted_set_key, min, max)
        end
      end
    end
  end
end
