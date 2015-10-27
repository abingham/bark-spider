// This is a page-object for the main page

var MainPage = function() {
    var url = 'http://localhost:6543',
        paramBlocks = element.all(by.repeater('simulation in simulations')),
        addParameterButton = element(by.id('add-parameters-btn')),
        deleteButtons = element.all(by.buttonText('delete'))
    ;

    this.get = function() {
        return browser.get(url);
    };

    this.paramCount = function () {
        return paramBlocks.count();
    };

    this.addParameter = function () {
        return addParameterButton.click();
    };

    this.deleteParameter = function(index) {
        return deleteButtons.get(index).click();
    };
};

module.exports = MainPage;
