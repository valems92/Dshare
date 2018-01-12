import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class SearchFirebase {
    let searchesRef = Database.database().reference().child("searches")

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
       searchesRef.observe(.childAdded, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Added")
        })
        
        searchesRef.observe(.childRemoved, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Removed")
        })
        
        searchesRef.observe(.childChanged, with: { (snapshot) in
            callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Changed")
        })
    }
    
    func stopObserveSearches() {
        searchesRef.removeAllObservers()
    }
}

