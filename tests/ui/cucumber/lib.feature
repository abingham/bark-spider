Feature: Simulation parameter sets
  As a user of bark-spider
  I should be able to create, edit, and delete parameter sets
  in order to configure the simulations I need.

  @dev
  Scenario: A preconfigure param set is provided
    Given I go to the front page
    Then there should be 1 parameter set

  # @dev
  # Scenario: Create new parameter set
  #   Given I go to the front page 	    	
  #   And I click "Add parameter set"
  #   Then there should be 2 parameter sets
