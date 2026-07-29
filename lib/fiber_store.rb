# frozen_string_literal: true

require 'fiber_store/version'
require 'fiber_store/middleware'
require 'fiber_store/railtie' if defined?(Rails::Railtie)

module FiberStore
  class << self
    def store
      Fiber[:fiber_store] ||= {}
    end

    def [](key)
      store[key]
    end

    def fetch(key, default = :__undefined__)
      warn 'warning: block supersedes default value argument' if block_given? && default != :__undefined__

      return store[key] if store.key?(key)
      return yield if block_given?
      return default unless default == :__undefined__

      raise KeyError, "key not found: #{key.inspect}"
    end

    def []=(key, value)
      store[key] = value
    end

    def clear!
      Fiber[:fiber_store] = {}
    end
  end
end
