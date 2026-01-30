# frozen_string_literal: true

module RailsMultistore
  class PushJob < ActiveJob::Base
    queue_as :default

    # Push a record to all configured stores
    # @param record [ActiveRecord::Base] The record to push
    def perform(record)
      return unless record.class.multistore_registry

      record.class.multistore_registry.push(record)
    end
  end
end
