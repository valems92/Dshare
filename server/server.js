const
    bodyParser = require('body-parser'),
    cors = require('cors'),
    express = require('express'),
    app = express();

app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());
app.use(cors());

app.use(require('./routes'));

app.listen(3000, function () {
    console.log("server starting on 300");
});