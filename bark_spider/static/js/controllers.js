(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http',
         function($scope, $http) {
             $scope.simulations = [];
             $scope.simulations.push({
                 name: 'software_development_rate',
                 assimilation_delay: 20,
                 elapsed: 0,
                 added: 0
             });

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
                         simulation_parameter_sets: $scope.simulations
                     }),
                     headers: {
                         'Content-Type': 'application/json'
                     }
                 }).then(function successCallback(response) {
                     console.log(response);

                     // TODO: How should we merge elapsed times? Should we at all?
                     $scope.labels = _.values(response.data[0].elapsed_time);

                     $scope.series = _.map(
                         response.data,
                         function(r) {
                             // TODO: How should we communicate series names?
                             return 'software development rate';
                         });

                     $scope.data = _.map(
                         response.data,
                         function(r) {
                             return _.values(r.software_development_rate);
                         });

                 }, function errorCallback(response) {
                     // TODO: on error...
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
