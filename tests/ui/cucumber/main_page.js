// This is a page-object for the main page

var MainPage = function() {
    var url = 'http://localhost:6543',
        paramBlocks = element.all(by.repeater('simulation in simulations'));

    this.get = function() {
        return browser.get(url);
    };

    this.paramCount = function () {
        return paramBlocks.count();
    };
};

module.exports = MainPage;
