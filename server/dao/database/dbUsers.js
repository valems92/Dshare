class DbUsers {
    constructor(db) {
        this.db = db;
        this.ref = db.ref('/users');
    }

    addNewUser(user, cb) {
        let userRef = this.ref.child(user.id);

        userRef.set(user).then(() => {
            cb(null, {
                id: user.id
            });
        }).catch((err) => {
            cb(err);
        })
    }
}

module.exports = DbUsers;