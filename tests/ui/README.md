# bark-spider UI tests
Cucumber-protractor UI tests for bark-spider.

## Setup and running

First you need to install protractor, cucumber, and the other dependencies:

  npm install -g protractor cucumber
  npm install 

(This assumes you've already installed node, npm, etc.)

Then update webdriver:

	webdriver-manager update

This is only necessary the first time you run.

Next, start the webdriver:

	webdriver-manager start

You then need to run bark-spider on port 6543. For example:

    pserve development.ini

Now you can run the tests:

	protractor cucumberConf.js
