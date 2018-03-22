class DbMessages {
    constructor(db) {
        this.db = db;
        this.ref = db.ref('/messages');
    }
}

module.exports = DbMessages;