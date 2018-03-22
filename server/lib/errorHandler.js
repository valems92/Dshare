'use strict';

class ErrorHandler {
    static onError(err, res) {
        res.status(err.code || 500).json({
            status: 'Error',
            message: err.message
        });
    }
}

module.exports = ErrorHandler;