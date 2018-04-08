const
    schedule = require('node-schedule'),
    express = require('express'),
    AppDao = require('./dao/appDao'),
    app = express();

// Every hour - check for flights updates
schedule.scheduleJob('2 * * * *', async () => {
    let searches = await AppDao.getAllSearches();

    let search;
    for (let i = 0; i < searches.length; i++) {
        search = searches[i];

        //TODO: check if flight arrival time has changed
        //TODO:     update arrival time search in DB
        //TODO:     change notification to search.suggestionSearch
    }
});

app.listen(3000, function () {
    console.log("server starting on 3000");
});