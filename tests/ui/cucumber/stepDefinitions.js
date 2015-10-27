// Use the external Chai As Promised to deal with resolving promises in
// expectations.
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;

// Chai expect().to.exist syntax makes default jshint unhappy.
// jshint expr:true

module.exports = function() {

    // this.Given(/^I go to(?: the website)? "([^"]*)"$/, function(url, next) {
    //     browser.get(url);
    //     next();
    // });
    this.Given(/^I go to the front page$/, function(next) {
        browser.get('http://localhost:6543');
        next();
    });

    this.Then(/^there should be (\d+) parameter set$/, function(expected_count, next) {
        expected_count = Number(expected_count);
        var blocks = element.all(by.repeater('simulation in simulations'));
        blocks.count().then(function(count) {
            expect(count).to.equal(expected_count);
            next();
        });
    });

    // this.Then(/the name label says "Hello ([^"]*)"$/, function(text, next) {
    //     var label = element(by.id("hello-label"));
    //     label.getText().then(function(r) {
    //         expect(r).to.equal("Hello " + text);
    //         next();
    //     });
    // });

    // this.Then(/^it should expose the correct global variables$/, function(next) {
    //     expect(protractor).to.exist;
    //     expect(browser).to.exist;
    //     expect(by).to.exist;
    //     expect(element).to.exist;
    //     expect($).to.exist;
    //     next();
    // });

    // this.Then(/the title should equal "([^"]*)"$/, function(text, next) {
    //     expect(browser.getTitle()).to.eventually.equal(text).and.notify(next);
    // });

};
