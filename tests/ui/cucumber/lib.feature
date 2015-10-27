Feature: Simulation parameter sets
  As a user of bark-spider
  I should be able to create, edit, and delete parameter sets
  in order to configure the simulations I need.

  Scenario: A preconfigured param set is provided
    Given I go to the front page
    Then there should be 1 parameter set

  Scenario: Create new parameter set
    Given I go to the front page 	    	
    And I add a parameter set
    Then there should be 2 parameter sets

  Scenario: Delete parameter set
    Given I go to the front page
    And I delete a parameter set
    Then there should be 0 parameter sets

  Scenario: Unhide parameter set
    Given I go to the front page
    Then parameter set 0 is hidden
    When I unhide parameter set 0
    Then parameter set 0 is visible

  Scenario: Hide parameter set
    Given I go to the front page
    And I unhide parameter set 0
    When I hide parameter set 0
    Then parameter set 0 is hidden
