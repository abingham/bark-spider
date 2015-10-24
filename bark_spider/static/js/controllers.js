(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http',
         function($scope, $http) {
             $scope.assimilation_delay = 20;
             $scope.elapsed = 0;
             $scope.added = 0;

             $scope.labels = ["January", "February", "March", "April", "May", "June", "July"];
             $scope.series = ['Series A', 'Series B'];
             $scope.data = [
                 [65, 59, 80, 81, 56, 55, 40],
                 [28, 48, 40, 19, 86, 27, 90]
             ];
             $scope.onClick = function (points, evt) {
                 console.log(points, evt);
             };
         }]);
}());
