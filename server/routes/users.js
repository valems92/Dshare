const 
    dao = require('../dao/index'),
    AuthUsers = dao.AuthUsers,
    DbUsers = dao.DbUsers,
    errorHandler = require('../lib/errorHandler'),
    router = require('express').Router();

router.post('/addNewUser', (req, res) => {
    let user = req.body;

    AuthUsers.addNewUser(user, (err, data) => {
        if (err) {
            errorHandler.onError(err, res);
        } else {
            DbUsers.addNewUser(data, (error, userId) => {
                res.json(userId);
            })
        }
    })
});

module.exports = router;