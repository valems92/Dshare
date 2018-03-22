const 
    DbSearches = require('../dao/index').DbSearches,
    errorHandler = require('../lib/errorHandler'),
    router = require('express').Router();

router.post('/addSearch', (req, res) => {
    let search = req.body;

    DbSearches.addSearch(search, (err, data) => {
        if (err) {
            errorHandler.onError(err, res);
        } else {
            res.json({});
        }
    })
});

router.get('/getSearchesByUserId/:id', (req, res) => {
    let id = req.params.id;

    DbSearches.getSearchesByUserId(id, (err, data) => {
        if (err) {
            errorHandler.onError(err, res);
        } else {
            res.json(data);
        }
    })
});

module.exports = router;