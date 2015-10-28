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

    this.Given(/^I go to the front page$/, function() {
        page = new MainPage();
        return page.get();
    });

    this.Then(/^there should be (\d+) parameter sets?$/, function(expected_count) {
        var expected_count = Number(expected_count);
        return page.paramCount().then(
            function(c) {
                expect(c).to.equal(expected_count);
            });
    });

    this.When(/^I add a parameter set$/, function () {
        return page.addParameter();
    });

    this.When(/^I delete a parameter set$/, function () {
        return page.deleteParameter(0);
    });

    this.Then(/^parameter set (\d+) is (hidden|visible)$/, function (index, state) {
        return page.parametersVisible(index).then(
            function(visible) {
                expect(visible).to.equal(state == 'visible' ? true : false);
            });
    });

    this.When(/^I (unhide|hide) parameter set (\d+)$/, function (state, index) {
        return page.showParameters(index, state == 'unhide' ? true : false);
    });

    this.When(/^I (include|exclude) parameter set (\d+)$/, function(state, index) {
        return page.includeParameters(index, state == 'include');
    });

    this.When(/^parameter set (\d+) is marked as (included|excluded)$/, function(index, state) {
        var included = page.parametersIncluded(index);
        var expected = state == 'included';
        return included == expected;
    });
};
