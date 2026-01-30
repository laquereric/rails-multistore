# frozen_string_literal: true

module RailsMultistore
  module Model
    extend ActiveSupport::Concern

    included do
      cattr_accessor :multistore_registry, instance_accessor: false
    end

    module ClassMethods
      # Configure the multistore for this model
      # @example
      #   multistore do
      #     store :primary_es, type: :elasticsearch, url: 'http://localhost:9200'
      #     store :secondary_es, type: :elasticsearch, url: 'http://localhost:9201'
      #   end
      def multistore(&block)
        self.multistore_registry = StoreRegistry.new
        self.multistore_registry.instance_eval(&block)
      end

      # Query all configured stores
      # @param query_string [String] The query string to search for
      # @return [Array] Aggregated results from all stores
      def multistore_query(query_string)
        return [] unless multistore_registry

        multistore_registry.query(query_string)
      end
    end

    # Push this record to all configured stores
    # This will enqueue a background job if async is enabled
    def multistore_push
      return unless self.class.multistore_registry

      if RailsMultistore.configuration&.async
        RailsMultistore::PushJob.set(queue: RailsMultistore.configuration.queue_name).perform_later(self)
      else
        self.class.multistore_registry.push(self)
      end
    end
  end
end
