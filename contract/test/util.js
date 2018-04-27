var _ = require("lodash");
var Promise = require("bluebird");

module.exports = {
    assertEvent: function(contract, filter, callback) {
        return new Promise((resolve, reject) => {
            if (contract[filter.event] == undefined) {
                console.log("event " + filter.event + " not found");
                return;
            }
            var event = contract[filter.event]();
            event.watch();
            event.get((error, logs) => {
                var log = _.filter(logs, filter);
                if (log) {
                    resolve(log);
                    callback(log);
                } else {
                    throw Error("Failed to find filtered event for " + filter.event);
                }
            });
            event.stopWatching();
        });
    }
}