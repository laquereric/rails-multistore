Feature: Multi-store Data Push
  As a developer
  I want to push data to multiple stores
  So that my data is replicated across different systems

  Scenario: Push to multiple Elasticsearch instances
    Given I have a model configured with two Elasticsearch stores
    When I create a new record
    And I call multistore_push
    Then the record should be pushed to both Elasticsearch instances

  Scenario: Push to different store types
    Given I have a model configured with Elasticsearch and MarkLogic stores
    When I create a new record
    And I call multistore_push
    Then the record should be pushed to both Elasticsearch and MarkLogic

  Scenario: Asynchronous push
    Given I have a model configured with async enabled
    When I create a new record
    And I call multistore_push
    Then a background job should be enqueued
