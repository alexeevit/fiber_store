# frozen_string_literal: true

module FiberStore
  class Railtie < ::Rails::Railtie
    initializer 'fiber_store.insert_middleware' do |app|
      insert_after =
        if ActionDispatch.const_defined? :RequestId
          ActionDispatch::RequestId
        else
          Rack::MethodOverride
        end

      app.config.middleware.insert_after insert_after, FiberStore::Middleware

      if ActiveSupport.const_defined?(:Reloader) && ActiveSupport::Reloader.respond_to?(:to_complete)
        ActiveSupport::Reloader.to_complete { FiberStore.clear! }
      elsif ActionDispatch.const_defined?(:Reloader) && ActionDispatch::Reloader.respond_to?(:to_cleanup)
        ActionDispatch::Reloader.to_cleanup { FiberStore.clear! }
      end
    end
  end
end
