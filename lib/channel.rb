class Channel
  attr_reader :thread, :sender, :channel_out

  def initialize(*params, &block)
    @writing_thread = nil
    @reading_thread = nil
    @channel_out = params.last || self
    @mutex = Mutex.new
    @sender = nil
    @value = []
    @write_mutex = Mutex.new
    if block_given? 
      @thread = new_thread { yield self }
    else 
      raise "Must implement run" unless respond_to?(:run)
      @thread = new_thread { run }
    end
  end

  def new_thread(&block)
    @thread = Thread.new { 
      begin
        yield block
      rescue => e
        puts "error running thread #{e}"
      end
    }
  end

  def write(value, sender = nil)
    @write_mutex.synchronize {
      @mutex.synchronize {
        @value.push(:value => value, :sender => sender)
        if @reading_thread.nil?
          @writing_thread = Thread.current
          @mutex.sleep
          @write_mutex.unlock
          @writing_thread = nil
        else
          @reading_thread.wakeup
          @reading_thread = nil
        end
      }
    }
  end

  def write_out(value)
    @channel_out.write(value, self)
  end

  def read
    @mutex.synchronize {
      if @writing_thread 
        @writing_thread.wakeup
        @writing_thread = nil
      else 
        @reading_thread = Thread.current
        @mutex.sleep
        @reading_thread = nil
      end
      response = @value.shift
      @sender = response[:sender]
      response[:value]
    }
  end


  def kill
    @thread.kill
  end
end
