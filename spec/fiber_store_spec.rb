# frozen_string_literal: true

require_relative 'spec_helper'

describe FiberStore do
  after(:each) { FiberStore.clear! }

  describe '#[]=' do
    it 'saves the value to the store' do
      described_class[:key] = 'value'
      expect(described_class[:key]).to eq('value')
    end
  end

  describe '#fetch' do
    context 'when the key is found' do
      before { described_class[:key] = 'value' }

      it 'returns the value' do
        expect(described_class.fetch(:key)).to eq('value')
      end
    end

    context 'when the key is not found' do
      context 'when default value is provided' do
        it 'returns the default value' do
          expect(described_class.fetch(:key, 'default')).to eq('default')
        end
      end

      context 'when a block is provided' do
        it 'calls the block' do
          expect(described_class.fetch(:key) { 'block result' }).to eq('block result')
        end
      end

      context 'when default value is not provided' do
        it 'raises a KeyError' do
          expect { described_class.fetch(:key) }.to raise_error(KeyError, 'key not found: :key')
        end
      end
    end

    context 'when both default value and block are provided' do
      it 'prints a warning' do
        expect { described_class.fetch(:key, 'default') { 'block result' } }
          .to output("warning: block supersedes default value argument\n").to_stderr
      end
    end
  end

  describe '#store' do
    it 'returns the whole store hash' do
      described_class[:key] = 'value'
      expect(described_class.store).to eq({ key: 'value' })
    end
  end

  describe '#clear!' do
    it 'clears the store' do
      described_class[:key] = 'value'
      described_class.clear!

      expect(described_class.store).to eq({})
    end
  end
end
