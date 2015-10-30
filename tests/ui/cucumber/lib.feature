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
    Then there should be 1 new parameter set

  Scenario: Delete parameter set
    Given I go to the front page
    And I delete a parameter set
    Then there should be 1 fewer parameter sets

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

  Scenario: Excluding a parameter set marks it as excluded
    Given I go to the front page
    When I exclude parameter set 0
    Then parameter set 0 is marked as excluded

  Scenario: Including a parameter set marks it as included
    Given I go to the front page
    When I exclude parameter set 0
    And I include parameter set 0
    Then parameter set 0 is marked as included

Feature: Running simulations
  As a use of bark-spider
  I should be able to run simulations and see graphs of the results

  @dev
  Scenario: The results plot is initially empty
    Given I go to the front page
    Then the plot is empty
  
  @dev
  Scenario: I can submit one parameter block for simulation
    Given I go to the front page
    When I run the simulation
    Then the plot is not empty

