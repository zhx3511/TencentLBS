let exec = require('cordova/exec');

exports.getTencentLoaction = function (successCallback,errorCallback,apikey) {
     exec(successCallback, errorCallback, 'TencentMap', 'getTencentLocation', [apikey]);
};
