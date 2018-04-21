const
  admin = require('firebase-admin'),
  serviceAccount = require('./key.json'),
  DB_URL = "https://dshare-ac2cb.firebaseio.com";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: DB_URL
});

const 
  db = admin.database(),
  ref = db.ref('/searches');

class AppDao {
    static async getAllSearches() {
        let searches = [];
        const dataSnapshot = await ref.orderByChild("foundSuggestion").equalTo(true).once("value");
        if (dataSnapshot) {
            let data = dataSnapshot.toJSON();

            let search;
            Object.keys(data).forEach(function (searchId) {
                search = data[searchId];
                // Keep future searches with flight number
                if (search.flightId && search.leavingTime > Date.now()) {
                    searches.push(search);
                }
            });
        }

        return searches;
    }
}

module.exports = AppDao;