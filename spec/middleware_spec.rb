# frozen_string_literal: true

require_relative 'spec_helper'

describe FiberStore::Middleware do
  after(:each) { FiberStore.clear! }

  subject(:middleware) { described_class.new(app) }
  let(:app) { App.new }

  def call_middleware(opts = {})
    _, _, body_proxy = middleware.call(opts)
    yield if block_given?
    body_proxy.tap(&:close)
  end

  it 'cleares the store after body proxy is closed' do
    call_middleware do
      expect(FiberStore.store).to eq({ key: 'value' })
    end
    expect(FiberStore.store).to eq({})
  end

  it 'does not mutate the response' do
    call_middleware.tap do |body_proxy|
      expect(body_proxy).to be_a(Rack::BodyProxy)
      expect(body_proxy.to_a).to eq(['Hello World'])
      expect(body_proxy.instance_variable_get(:@body)).to eq(['Hello World'])
    end
  end

  context 'when an error was raised' do
    it 'cleares the store after request' do
      expect { call_middleware({ error: true }) }.to raise_error(RuntimeError)
      expect(FiberStore.store).to eq({})
    end
  end

  context 'when the store was touched before request threads spawn' do
    let(:app) { ConcurrentApp.new }

    it 'does not bleed data between threads serving concurrent requests' do
      FiberStore.store

      step = Queue.new
      gate = Queue.new
      seen = {}

      thread_a =
        Thread.new do
          call_middleware({ user: 'userA', seen: seen, before_read: -> { step << :a_wrote; gate.pop } })
        end

      thread_b =
        Thread.new do
          step.pop
          call_middleware({ user: 'userB', seen: seen, before_read: -> { gate << :go } })
        end

      [thread_a, thread_b].each(&:join)

      expect(seen['userA']).to eq('userA')
      expect(seen['userB']).to eq('userB')
    end
  end
end

class App
  def call(env)
    FiberStore[:key] = 'value'

    raise RuntimeError if env[:error]

    [200, {}, ['Hello World']]
  end
end

class ConcurrentApp
  def call(env)
    FiberStore[:session_key] = env[:user]
    env[:before_read].call
    env[:seen][env[:user]] = FiberStore[:session_key]

    [200, {}, ['Hello World']]
  end
end
