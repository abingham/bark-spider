(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    // Creates a single sample parameter set
    var initialize_params = function($scope) {
        var params = $scope.add_parameter_set('+10 @ 100d');
        params.assimilation_delay = 20;
        params.training_overhead_proportion = 0.25;
        params.interventions = 'add 100 10';
    };

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http',
         function($scope, $http) {
             $scope.simulations = [];

             // Create a new parameter set and append it to the list.
             $scope.add_parameter_set = function(name) {
                 var params = {
                     name: name,
                     included: true,
                     assimilation_delay: 20,
                     training_overhead_proportion: 0.25,
                     interventions: ''
                 };

                 $scope.simulations = $scope.simulations.concat(params);
                 return params;
             };

             // Remove the parameter set at INDEX
             $scope.remove_parameter_set = function(index) {
                 $scope.simulations.splice(index, 1);
             };

             $scope.labels = [];
             $scope.series = [];
             $scope.data = [];
             $scope.options = {
                 pointDot: false
             };

             // Run a simulation using the currently configured parameter sets
             $scope.simulate = function() {
                 $http({
                     method: 'POST',
                     url: '/simulate',
                     data: JSON.stringify({
                         // Filter out the parameter sets which have
                         // been excluded.
                         simulation_parameter_sets: _.filter(
                             $scope.simulations,
                             function (s) {
                                 return s.included;
                             })
                     }),
                     headers: {
                         'Content-Type': 'application/json'
                     }
                 }).then(function successCallback(response) {
                     // Get all of the elapsed times from the response
                     var elapsed_times = _.map(
                         _.values(response.data),
                         function(s) { return s.elapsed_time; }
                     );

                     // Find the longest set of elapsed times. This
                     // will define how large the plot needs to be.
                     var longest_series = _.reduce(
                         elapsed_times,
                         function(accum, next){
                             return _.size(next) > accum.length ? _.values(next) : accum;
                         },
                         []);

                     $scope.labels = _.values(longest_series);

                     $scope.series = [];
                     $scope.data = [];

                     // Collect the series names and rate values from
                     // the response.
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

             // Create a starter parameter set.
             initialize_params($scope);
         }]);

    barkSpiderControllers.controller(
        'ParameterSetCtrl',
        ['$scope',
         function($scope) {
             $scope.opened = false;
         }]);
}());
