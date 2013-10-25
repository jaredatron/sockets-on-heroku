require Bundler.root.join('redis')

class EventBus
  REDIS_KEY = 'events'
  def initialize(&block)
    block_given? or raise ArgumentError
    @thread = Thread.new do
      redis.subscribe(REDIS_KEY) do |on|
        on.message do |channel, msg|
          block.call(msg)
        end
      end
    end
  end
  attr_reader :thread

  def redis
    Redis.current
  end

  def send message
    redis.publish(REDIS_KEY, message)
  end
end


# events = EventBus.new do |msg|
#   puts "MESSAGE RECIEVED: #{msg.inspect}"
# end


# binding.pry
