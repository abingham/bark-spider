// This is a page-object for the main page

var MainPage = function() {
    var url = 'http://localhost:6543',
        paramBlocks = element.all(by.repeater('simulation in simulations')),
        addParameterButton = element(by.id('add-parameters-btn')),
        deleteButtons = element.all(by.buttonText('delete')),
        parameterForms = element.all(by.className('parameter-set-form')),
        visibilityButtons = element.all(by.className('hide-show-parameters')),
        inclusionButtons = element.all(by.className('include-exclude-parameters'))
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

    this.showParameters = function(index, show) {
        var button = visibilityButtons.get(index);
        var opened = button.evaluate('opened');
        if (opened != show) {
            return button.click();
        }
        return button;
    };

    this.parametersVisible = function(index) {
        return parameterForms.get(index).isDisplayed();
    };

    this.includeParameters = function(index, include) {
        var button = inclusionButtons.get(index);
        if (this.parametersIncluded(index) != include) {
            return button.click();
        }
        return button;
    };

    this.parametersIncluded = function(index) {
        var button = inclusionButtons.get(index);
        return button.evaluate('simulation.included');
    };
};

module.exports = MainPage;
