(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    var initialize_params = function($scope) {
        var params = $scope.add_parameter_set('+10 @ 100d');
        params.assimilation_delay = 20;
        params.elapsed = 100;
        params.added = 10;
    };

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http',
         function($scope, $http) {
             $scope.simulations = [];

             $scope.add_parameter_set = function(name) {
                 var params = {
                     name: name,
                     assimilation_delay: 20,
                     elapsed: 100,
                     added: 20
                 };

                 $scope.simulations = $scope.simulations.concat(params);
                 return params;
             };

             $scope.remove_parameter_set = function(index) {
                 $scope.simulations.splice(index, 1);
             };

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

                     var elapsed_times = _.map(
                         _.values(response.data),
                         function(s) { return s.elapsed_time; }
                     );

                     var longest_series = _.reduce(
                         elapsed_times,
                         function(accum, next){
                             return _.size(next) > accum.length ? _.values(next) : accum;
                         },
                         []);

                     $scope.labels = _.values(longest_series);

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

             initialize_params($scope);
         }]);
}());
