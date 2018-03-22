const router = require('express').Router();

router.use('/users', require('./users'));
router.use('/searches', require('./searches'));
router.use('/messages', require('./messages'));

module.exports = router;