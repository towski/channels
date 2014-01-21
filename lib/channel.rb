class Channel
  attr_reader :thread

  def initialize(*params, &block)
    @writing_thread = nil
    @reading_thread = nil
    @mutex = Mutex.new
    @value = []
    @write_mutex = Mutex.new
    @thread = Thread.new do
      yield self
    end
  end

  def write(value)
    @write_mutex.synchronize {
      @mutex.synchronize {
        @value.push value
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
      @value.shift
    }
  end

  def kill
    @thread.kill
  end
end
