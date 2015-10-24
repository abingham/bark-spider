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

             $scope.labels = [];
             $scope.series = [];
             $scope.data = [];
             $scope.options = {
                 pointDot: false
             };

             $scope.simulate = function() {
                 $http({
                     method: 'POST',
                     url: '/simulate',
                     data: JSON.stringify({
                         elapsed: $scope.elapsed,
                         added: $scope.added
                     }),
                     headers: {
                         'Content-Type': 'application/json'
                     }
                 }).then(function successCallback(response) {
                     console.log(response);
                     $scope.labels = _.values(response.data.elapsed_time);
                     $scope.series = ['software development rate'];

                     var rates = _.values(response.data.software_development_rate);

                     $scope.data = [rates];

                 }, function errorCallback(response) {
                     var y = 4;
                 });

             };

             // $scope.labels = ["January", "February", "March", "April", "May", "June", "July"];
             // $scope.series = ['Series A', 'Series B'];
             // $scope.data = [
             //     [65, 59, 80, 81, 56, 55, 40],
             //     [28, 48, 40, 19, 86, 27, 90]
             // ];
             // $scope.onClick = function (points, evt) {
             //     console.log(points, evt);
             // };
         }]);
}());
