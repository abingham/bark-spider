(function() {
    'use strict';

    var barkSpiderControllers = angular.module('barkSpiderControllers', []);

    // Creates a single sample parameter set
    var initialize_params = function($scope) {
        var sim = $scope.add_simulation('+10 @ 100d');
        sim.parameters.assimilation_delay = 20;
        sim.parameters.training_overhead_proportion = 0.25;
        sim.parameters.interventions = 'add 100 10';
    };

    barkSpiderControllers.controller(
        'BarkSpiderCtrl',
        ['$scope', '$http', '$q',
         function($scope, $http, $q) {
             $scope.simulations = [];

             $scope.error_messages = [];

             // Create a new parameter set and append it to the list.
             $scope.add_simulation = function(name) {
                 var sim = {
                     name: name,
                     included: true,
                     parameters: {
                         assimilation_delay: 20,
                         training_overhead_proportion: 0.25,
                         interventions: ''
                     }
                 };

                 $scope.simulations = $scope.simulations.concat(sim);
                 return sim;
             };

             // Remove the parameter set at INDEX
             $scope.remove_parameter_set = function(index) {
                 $scope.simulations.splice(index, 1);
             };

             // Find parameter sets which are included/enabled
             $scope.included_params = function() {
                 return _.filter(
                     $scope.simulations,
                     function (s) {
                         return s.included;
                     });
             };

             $scope.labels = [];
             $scope.series = [];
             $scope.data = [];

             $scope.options = {
                 pointDot: false
             };

             // Run a simulation using the currently configured parameter sets
             $scope.simulate = function() {
                 var labels = [];
                 var series = [];
                 var data = [];

                 // The strategy is to make all of the requests in
                 // parallel, accumulating the results into the
                 // variables labels, series, and data. Once we have
                 // them all, we update the scope variables at one
                 // time. The idea is that this prevents multiple
                 // renderings of the same data, i.e. as it arrives
                 // piecemeal.

                 $scope.error_messages = [];
                 var requests = _.map(
                     $scope.included_params(),
                     function (p) {
                         return $http({
                             method: 'POST',
                             url: '/simulate',
                             data: JSON.stringify(p),
                             headers: {
                                 'Content-Type': 'application/json'
                             }
                         }).then(
                             function(response) {
                                 
                                 return $http({
                                     method: 'GET',
                                     url: response.data.url
                                 }).then(function(response) {
                                     var name = response.data.name;
                                     var results = response.data.results;
                                     var parameters = response.data.parameters;
                                     
                                     // Only update labels if we have more data points
                                     var elapsed_time = results.elapsed_time;
                                     if (_.size(elapsed_time) > labels.length) {
                                         labels = _.values(elapsed_time);
                                     }
                                     
                                     series.push(name);
                                     data.push(_.values(results.software_development_rate));
                                 });
                             },
                             function(response) {
                                 $scope.error_messages.push(response.data);
                             }
                         );
                     });

                 $q.all(requests).then(function(_) {
                     $scope.labels = labels;
                     $scope.series = series;
                     $scope.data = data;
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
