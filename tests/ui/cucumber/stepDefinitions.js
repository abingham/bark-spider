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

    this.Then(/^there should be (\d+) parameter set$/, function(expected_count, next) {
        var expected_count = Number(expected_count);
        page.paramCount().then(
            function(c) {
                expect(c).to.equal(expected_count);
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
