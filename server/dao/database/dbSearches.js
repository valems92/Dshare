class DbSearches {
    constructor(db) {
        this.db = db;
        this.ref = db.ref('/searches');
    }

    addSearch(search, cb) {
        let searchRef = this.ref.child(search.id);

        searchRef.set(search).then(() => {
            cb(null);
        }).catch((err) => {
            cb(err);
        })
    }

    getSearchesByUserId(id, cb) {
        this.ref.orderByChild("userId").equalTo(id).once("value", (dataSnapshot) => {
            let data = dataSnapshot.toJSON();
            let searches = [];

            Object.keys(data).forEach(function(searchId) {
                searches.push(data[searchId]);
            });

            cb(null, searches);
        });
    }
}

module.exports = DbSearches;