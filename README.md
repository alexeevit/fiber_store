# FiberStore [![CI](https://github.com/alexeevit/fiber_store/actions/workflows/ci.yml/badge.svg)](https://github.com/alexeevit/fiber_store/actions/workflows/ci.yml) [![Gem Version](https://badge.fury.io/rb/fiber_store.svg)](https://badge.fury.io/rb/fiber_store)

A per-request Fiber-local store for Rack-based applications. Practically, a copy of [request_store](https://github.com/steveklabnik/request_store), but based on Fiber-local storage instead of threads.

### Differences from RequestStore

RequestStore stores data in `Thread.current`. Each Fiber has its own thread-local context, so the store is not shared with nested Fibers. As a result, the store appears empty in async jobs:
```ruby
RequestStore.store[:hello] = 'world'

Async do
  puts RequestStore.store # => {}
end.wait

puts RequestStore.store # => { hello: "world" }
```

FiberStore uses `Fiber[]` for storage, making the data accessible from nested Fibers:
```ruby
FiberStore[:hello] = 'world'

Async do
  puts FiberStore.store # => { hello: "world" }
end.wait

puts FiberStore.store # => { hello: "world" }
```

RequestStore used `Fiber[]` for storage in version 1.6.0. This caused issues with [sidekiq integration](https://github.com/steveklabnik/request_store/issues/96) and [propagation of the store into nested threads](https://github.com/steveklabnik/request_store/issues/98), which led the approach being reverted.

**Warning**

The root Fiber is shared across nested threads. As a result, FiberStore data will be visible inside threads spawned from the root Fiber:
```ruby
FiberStore[:hello] = 'world'

Thread.new do
  puts FiberStore.store # => { hello: "world" }
end.join
```

## Requirements

Ruby >= 3.2

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'fiber_store'
```

In Rails applications, the required middleware is used automatically by the Railtie.

### For non-Rails applications

To ensure the storage is cleared before and after each request, it's required to use the middleware manually:
```ruby
require 'fiber_store'

use FiberStore::Middleware

run do |env|
  FiberStore[:counter] ||= 0
  FiberStore[:counter] += 1

  [200, {}, [FiberStore[:counter].to_s]] # => always 1
end
```

## Usage

```ruby
# Set and get values
FiberStore[:hello] = 'world'
FiberStore[:hello] # => 'world'

# Fetch
FiberStore.fetch(:hello) # => 'world'
FiberStore.fetch(:with_default, 'default') # => 'default'
FiberStore.fetch(:with_block) { 'block result' } # => 'block result'
FiberStore.fetch(:no_value) # => key not found: :no_value (KeyError)

# Store
FiberStore.store # => { hello: "world" }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Open a new Pull Request

Don't forget to run the tests with `bin/rspec spec`.
