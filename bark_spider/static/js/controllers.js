(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http',
         function($scope, $http) {
             $scope.simulations = [];
             $scope.simulations.push({
                 name: '+10 @ 100d',
                 assimilation_delay: 20,
                 elapsed: 100,
                 added: 10
             });

             $scope.simulations.push({
                 name: '+20 @ 100d',
                 assimilation_delay: 20,
                 elapsed: 100,
                 added: 20
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

                     // TODO: How should we merge elapsed times? Should we at all? We need to pick the longest.
                     var first_series = _.values(response.data)[0];
                     $scope.labels = _.values(first_series.elapsed_time);

                     $scope.series = [];
                     $scope.data = [];

                     _.map(
                         _.pairs(response.data),
                         function (p) {
                             $scope.series.push(p[0]);
                             $scope.data.push(_.values(p[1].software_development_rate));
                         });
                 }, function errorCallback(response) {
                     // TODO: on error...
                 });

             };
         }]);
}());
