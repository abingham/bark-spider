// Use the external Chai As Promised to deal with resolving promises in
// expectations.
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;

// Chai expect().to.exist syntax makes default jshint unhappy.
// jshint expr:true
2
var MainPage = require('./main_page.js');

module.exports = function() {

    var page,
        startParamCount;

    this.Given(/^I go to the front page$/, function() {
        page = new MainPage();
        return page.get().then(function() {
            page.paramCount().then(function(c) {
                startParamCount = c;
            });
        });
    });

    this.Then(/^there should be (\d+) parameter sets?$/, function(count) {
        count = Number(count);

        return page.paramCount().then(
            function(c) {
                expect(c).to.equal(count);
            });
    });

    this.Then(/^there should be (\d+) (new|fewer) parameter sets?$/, function(count, direction) {
        count = Number(count);

        var expected = direction == 'new' ? startParamCount + count : startParamCount - count;

        return page.paramCount().then(
            function(c) {
                expect(c).to.equal(expected);
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

    this.Then(/^the plot is( not)? empty$/, function(state) {
        var expected = (state) ? false : true;

        return page.chartIsEmpty().then(function(e) {
            expect(e).to.equal(expected);
        });
    });

    this.When(/^I run the simulation$/, function() {
        return page.runSimulation();
    });
};
