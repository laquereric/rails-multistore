# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RailsMultistore::Model do
  let(:test_model) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'articles'
      include RailsMultistore::Model
    end
  end

  describe '.multistore' do
    it 'creates a store registry' do
      test_model.multistore do
        store :test_store, type: :elasticsearch, url: 'http://localhost:9200'
      end

      expect(test_model.multistore_registry).to be_a(RailsMultistore::StoreRegistry)
      expect(test_model.multistore_registry.stores.size).to eq(1)
    end

    it 'allows multiple stores of the same type' do
      test_model.multistore do
        store :primary_es, type: :elasticsearch, url: 'http://localhost:9200'
        store :secondary_es, type: :elasticsearch, url: 'http://localhost:9201'
      end

      expect(test_model.multistore_registry.stores.size).to eq(2)
    end
  end

  describe '#multistore_push' do
    let(:record) { test_model.new(id: 1, title: 'Test Article') }

    before do
      test_model.multistore do
        store :test_store, type: :elasticsearch, url: 'http://localhost:9200'
      end
    end

    context 'when async is enabled' do
      before do
        RailsMultistore.configure do |config|
          config.async = true
        end
      end

      it 'enqueues a push job' do
        expect(RailsMultistore::PushJob).to receive(:perform_later).with(record)
        record.multistore_push
      end
    end

    context 'when async is disabled' do
      before do
        RailsMultistore.configure do |config|
          config.async = false
        end
      end

      it 'pushes synchronously' do
        expect(test_model.multistore_registry).to receive(:push).with(record)
        record.multistore_push
      end
    end
  end

  describe '.multistore_query' do
    before do
      test_model.multistore do
        store :test_store, type: :elasticsearch, url: 'http://localhost:9200'
      end
    end

    it 'queries all configured stores' do
      expect(test_model.multistore_registry).to receive(:query).with('test query')
      test_model.multistore_query('test query')
    end
  end
end
