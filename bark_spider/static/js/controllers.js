(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope',
         function($scope) {
             $scope.assimilation_delay = 20;
         }]);
}());
