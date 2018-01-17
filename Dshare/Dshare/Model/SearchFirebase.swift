import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class SearchFirebase {
    let searchesRef = Database.database().reference().child("searches")
    var observers:[DatabaseReference] = []

    func addNewSearch(search: Search, completionBlock:@escaping (Error?)->Void){
        let searchRef = searchesRef.child(search.id)
        
        searchRef.setValue(search.toJson()) {(error, dbref) in
            if(error != nil) {
                completionBlock(error)
            } else {
                completionBlock(nil)
            }
        }
    }
    
    func getSearchesByUserId(id:String, callback:@escaping (Error?, [Search])->Void) {
        searchesRef.queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value) {(snapshot:DataSnapshot) in
            var searches = [Search]()
            for search in snapshot.children.allObjects {
                if let searchData = search as? DataSnapshot {
                    if let json = searchData.value as? Dictionary<String,Any> {
                        searches.append(Search(fromJson: json))
                    }
                }
            }
            
            callback(nil, searches)
        }
    }
    
    func getAllSearches(callback:@escaping ([Search])->Void) {
        searchesRef.observeSingleEvent(of: .value) {(snapshot: DataSnapshot) in
            var searches = [Search]();
            for search in snapshot.children.allObjects {
                if let searchData = search as? DataSnapshot {
                    if let json = searchData.value as? Dictionary<String,Any> {
                        searches.append(Search(fromJson: json))
                    }
                }
            }
            callback(searches)
        }
    }
    
    func startObserveSearches(callback:@escaping(Search?,String)->Void) {
        let ref = Database.database().reference()
        ref.child("searches").observe(.childAdded, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Added")
        })
        
        ref.child("searches").observe(.childRemoved, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Removed")
        })
        
        ref.child("searches").observe(.childChanged, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Changed")
        })
        
        observers.append(ref.child("searches"))
    }
    
    func stopObserves() {
        for observe in observers {
            observe.removeAllObservers()
        }
        observers.removeAll()
    }
    
    func updateSearch(searchId:String, value:[AnyHashable : Any]) {
        searchesRef.child(searchId).updateChildValues(value) {(error, dbref) in
            if(error != nil) {
                print("There was an error while updating search in DB")
            }
        }
    }
    
    func removeSuggestionsIdOfSearch(searchId:String) {
        searchesRef.child(searchId).child("suggestionsId").removeValue()
    }
    
    func startObserveCurrentUserSearches(id:String, callback:@escaping([String], String)->Void) {
        getSearchesByUserId(id: id) { (error, searches) in
            if error == nil {
                for search in searches {
                    self.searchesRef.child(search.id).observe(.childAdded, with: { (snapshot) in
                        if snapshot.key == "suggestionsId", let value = snapshot.value as? [String] {
                            callback(value, search.id)
                        }
                    })
                    self.observers.append(self.searchesRef.child(search.id))
                }
            }
        }
    }
}

