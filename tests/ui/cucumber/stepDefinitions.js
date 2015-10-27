// Use the external Chai As Promised to deal with resolving promises in
// expectations.
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;

// Chai expect().to.exist syntax makes default jshint unhappy.
// jshint expr:true

var MainPage = require('./main_page.js');

module.exports = function() {

    var page,
        startParamCount;

    this.Given(/^I go to the front page$/, function(next) {
        page = new MainPage();
        page.get().then(next);
    });

    this.Then(/^there should be (\d+) parameter sets?$/, function(expected_count, next) {
        var expected_count = Number(expected_count);
        page.paramCount().then(
            function(c) {
                expect(c).to.equal(expected_count);
                next();
            });
    });

    this.When(/^I add a parameter set$/, function (next) {
        page.addParameter().then(next);
    });

    this.When(/^I delete a parameter set$/, function (next) {
        page.deleteParameter(0).then(next);
    });

};
