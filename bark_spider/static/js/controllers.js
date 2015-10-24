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

             $scope.current_image = null;

             // TODO: Can't we use a service for this?
             $scope.update_current_image = function() {
                 $http({
                     method: 'GET',
                     url: '/simulate/100/10',
                     headers: {
                         'responseType': "image/png"
                     }
                 }).then(function successCallback(response) {
                     $scope.current_image = response;
                 }, function errorCallback(response) {
                     // called asynchronously if an error occurs
                     // or server returns response with an error status.
                 });
             };

             $scope.update_current_image();
         }]);
}());
