class AuthUsers {
    constructor(auth) {
        this.auth = auth;
    }

    addNewUser(user, cb) {
        let properties = {
            email: user.email,
            password: user.password
        }

        this.auth.createUser(properties).then((userRecord) => {
            user.id = userRecord.uid;
            cb(null, user);
        }).catch((err) => {
            cb(err);
        });
    }
}

module.exports = AuthUsers;