import Foundation
import UIKit

//let notifyStudentListUpdate = "com.menachi.NotifyStudentListUpdate"

extension Date {
    func toFirebase()->Double{
        return self.timeIntervalSince1970 * 1000
    }
    
    static func fromFirebase(_ interval:String)->Date{
        return Date(timeIntervalSince1970: Double(interval)!)
    }
    
    static func fromFirebase(_ interval:Double)->Date{
        if (interval>9999999999){
            return Date(timeIntervalSince1970: interval/1000)
        }else{
            return Date(timeIntervalSince1970: interval)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}

class ModelNotificationBase<T>{
    var name:String?
    
    init(name:String) {
        self.name = name
    }
    
    func observe(callback:@escaping (T?, Any?)->Void)->Any {
        return NotificationCenter.default.addObserver(forName: NSNotification.Name(name!), object: nil, queue: nil) { (data) in
            if let dataContent = data.userInfo?["data"] as? T {
                callback(dataContent, data.userInfo?["params"])
            }
        }
    }
    
    func post(data:T, params:Any?){
        NotificationCenter.default.post(name: NSNotification.Name(name!), object: self, userInfo: ["data": data, "params": params ?? ""])
    }
}

class ModelNotification{
    static let SuggestionsUpdate = ModelNotificationBase<Search>(name: "SuggestionsUpdateNotification")
    static let SearchUpdate = ModelNotificationBase<[String]>(name: "SearchUpdateNotification")
    
    static func removeObserver(observer:Any){
        NotificationCenter.default.removeObserver(observer)
    }
}

class Model{
    static let instance = Model()
    
    //lazy private var modelSql:ModelSql? = ModelSql()
    lazy private var userFirebase:UserFirebase? = UserFirebase()
    lazy var messageFirebase:MessageFirebase? = MessageFirebase()
    lazy private var searchFirebase:SearchFirebase? = SearchFirebase()
    
    private init(){
    }
    
    func clear() {
        self.searchFirebase?.stopObserves()
    }
    
    /*************************** User ***************************/
    
    func checkIfUserLoggedIn(completionBlock:@escaping (Bool?)->Void){
        userFirebase?.checkIfUserLoggedIn() {(isUserLoggedIn) in
            completionBlock(isUserLoggedIn)
        }
    }
    
    func addNewUser(user:User, completionBlock:@escaping (String?, Error?)->Void){
        userFirebase?.addNewUser(user: user){(newUserID, error) in
            completionBlock(newUserID, error)
            //st.addStudentToLocalDb(database: self.modelSql?.database)
        }
    }
    
    func getCurrentUser(callback:@escaping (User)->Void){
        let id:String = self.getCurrentUserUid();
        userFirebase?.getUserById(id:id){(user) in
            if user != nil {
                callback(user!)
            }
        }
    }
    
    func getCurrentUserUid() -> String {
        let id:String? = userFirebase?.getCurrentUserUid()
        return id!
    }
    
    func signInUser(email:String, password:String, completionBlock:@escaping (Error?)->Void){
        userFirebase?.signInUser(email: email, password: password){(error) in
            completionBlock(error)
        }
    }
    
    func signOutUser(completionBlock:@escaping (Error?)->Void) {
        userFirebase?.signOutUser {(error) in
            completionBlock(error)
        }
    }
    
    func getUserById(id:String, callback:@escaping (User)->Void){
        userFirebase?.getUserById(id: id){(user) in
            if user != nil {
                callback(user!)
            }
        }
    }
    
    func updateUserInfo(fName:String, lName:String, email:String, phoneNum:String, gender:String){
        userFirebase?.updateUserInfo(fName:fName, lName:lName, email:email, phoneNum:phoneNum, gender:gender)
    }
    
    func updatePassword(newPassword:String){
        userFirebase?.updatePassword(newPassword: newPassword)
    }
    
     /****** Images ******/
    
    func saveImage(image:UIImage, name:String, callback:@escaping (String?)->Void){
        userFirebase?.saveImageToFirebase(image: image, name: name, callback: {(url) in
            if (url != nil){
                self.saveImageToFile(image: image, name: name)
            }
            callback(url)
        })
    }
    
    func getImage(urlStr:String, callback:@escaping (UIImage?)->Void) {
        let finalUrlStr = (urlStr == "") ? Utils.instance.defaultIconUrl : urlStr
        
        let url = URL(string: finalUrlStr)
        let localImageName = url!.lastPathComponent
        if let image = self.getImageFromFile(name: localImageName){
            callback(image)
        }else{
            userFirebase?.getImageFromFirebase(url: urlStr, callback: { (image) in
                if (image != nil){
                    self.saveImageToFile(image: image!, name: localImageName)
                }
                callback(image)
            })
        }
    }
    
    private func saveImageToFile(image:UIImage, name:String){
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
    /*************************** Search ***************************/

    func addNewSearch(search:Search, completionBlock:@escaping (Error?)->Void){
        searchFirebase?.addNewSearch(search: search){ (error) in
            completionBlock(error)
        }
    }
    
    func getCorrentUserSearches(completionBlock:@escaping (Error?, [Search])->Void){
        let id = getCurrentUserUid()
        searchFirebase?.getSearchesByUserId(id: id, callback: completionBlock);
    }
    
    func getSearchesByUserId(id:String, completionBlock:@escaping (Error?, [Search])->Void){
        searchFirebase?.getSearchesByUserId(id: id, callback: completionBlock);
    }
    
    func getAllSearches(completionBlock:@escaping([Search])->Void) {
        searchFirebase?.getAllSearches(callback: completionBlock);
    }
    
    func startObserveSearches() {
        searchFirebase?.startObserveSearches(callback: { (search, status) in
            ModelNotification.SuggestionsUpdate.post(data: search!, params: status)
        })
    }
    
    func startObserveCurrentUserSearches() {
        let id = getCurrentUserUid()
        searchFirebase?.startObserveCurrentUserSearches(id: id, callback: { (suggestionsId) in
            ModelNotification.SearchUpdate.post(data: suggestionsId, params: nil)
        })
    }
    
    func updateSearch(searchId:String, value:[AnyHashable : Any]) {
        searchFirebase?.updateSearch(searchId:searchId, value:value)
    }
    
    /*************************** Message ***************************/

    /*func addNewMessage(message:Message, completionBlock:@escaping (Error?)->Void){
        messageFirebase?.addNewMessage(message: message){ (error) in
            completionBlock(error)
        }
    }
  
    func observeMessages(callback:@escaping (Message?)->Void) {
        messageFirebase?.observeMessages() { (message) in
            callback(message)
        }
    }*/
    
    
    
    func sendMessage(senderID:String, senderName:String, recieversIds:[String], text:String) {
        messageFirebase?.sendMessage(senderID: senderID, senderName: senderName, recieversIds:recieversIds, text: text)
    }
    
    func removeObserver() {
        messageFirebase?.removeObserver()
    }
    
    
    
    /* func getAllStudents(callback:@escaping ([Student])->Void){
     // get last update date from SQL
     let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Student.ST_TABLE)
     
     // get all updated records from firebase
     userFirebase?.getAllStudents(lastUpdateDate, callback: { (students) in
     //update the local db
     print("got \(students.count) new records from FB")
     var lastUpdate:Date?
     for st in students{
     st.addStudentToLocalDb(database: self.modelSql?.database)
     if lastUpdate == nil{
     lastUpdate = st.lastUpdate
     }else{
     if lastUpdate!.compare(st.lastUpdate!) == ComparisonResult.orderedAscending{
     lastUpdate = st.lastUpdate
     }
     }
     }
     
     //upadte the last update table
     if (lastUpdate != nil){
     LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Student.ST_TABLE, lastUpdate: lastUpdate!)
     }
     
     //get the complete list from local DB
     let totalList = Student.getAllStudentsFromLocalDb(database: self.modelSql?.database)
     
     //return the list to the caller
     callback(totalList)
     })
     } */
    
    /* func getAllStudentsAndObserve(){
     // get last update date from SQL
     let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Student.ST_TABLE)
     
     // get all updated records from firebase
     userFirebase?.getAllStudentsAndObserve(lastUpdateDate, callback: { (students) in
     //update the local db
     print("got \(students.count) new records from FB")
     var lastUpdate:Date?
     for st in students{
     st.addStudentToLocalDb(database: self.modelSql?.database)
     if lastUpdate == nil{
     lastUpdate = st.lastUpdate
     }else{
     if lastUpdate!.compare(st.lastUpdate!) == ComparisonResult.orderedAscending{
     lastUpdate = st.lastUpdate
     }
     }
     }
     
     //upadte the last update table
     if (lastUpdate != nil){
     LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Student.ST_TABLE, lastUpdate: lastUpdate!)
     }
     
     //get the complete list from local DB
     let totalList = Student.getAllStudentsFromLocalDb(database: self.modelSql?.database)
     
     //return the list to the observers using notification center
     NotificationCenter.default.post(name: Notification.Name(rawValue:
     notifyStudentListUpdate), object:nil , userInfo:["students":totalList])
     })
     } */
}
