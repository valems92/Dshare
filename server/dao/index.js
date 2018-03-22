const 
  DbUsers = require('./database/dbUsers'),
  DbSearches = require('./database/dbSearches'),
  DbMessages = require('./database/dbMessages'),

  AuthUsers = require('./auth/authUsers'),
    
  admin = require('firebase-admin'),
  serviceAccount = require('./key.json'),
  DB_URL = "https://dshare-ac2cb.firebaseio.com";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: DB_URL
});

const 
  db = admin.database(),
  auth = admin.auth(),
  storage = admin.storage();

module.exports = {
  DbUsers: new DbUsers(db),
  DbSearches: new DbSearches(db),
  DbMessages: new DbMessages(db),

  AuthUsers: new AuthUsers(auth)
};