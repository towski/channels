Implement Go style channels in ruby, asynchronous threads that can pass messages through a blocking channel.

In the following example, each separate channel is writing to a main channel whenever it receives a response, and the main channel pops the responses off as soon as it receives them. 

See Rob Pike's go talk: http://www.youtube.com/watch?v=f6kdp27TYZs

```ruby
require_relative 'channel'
require 'net/http'

Channel.new do |main|
  Channel.new do
    main.write Net::HTTP.get('indietorrents.com', '/index.html')
  end
  Channel.new do
    main.write Net::HTTP.get('google.com', '/index.html')
  end
  Channel.new do
    main.write Net::HTTP.get('yelp.com', '/index.html')
  end
  loop do
    puts main.read
  end
end

sleep
```
