# frozen_string_literal: true

require 'rack/body_proxy'

module FiberStore
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      returned = false
      status, headers, body = @app.call(env)

      body =
        Rack::BodyProxy.new(body) do
          FiberStore.clear!
        end

      returned = true

      [status, headers, body]
    ensure
      FiberStore.clear! unless returned
    end
  end
end
