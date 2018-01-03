import Foundation
import FirebaseDatabase

class Search {
    var id:String;
    var userId:String;
    var startingPoint:String;
    var destination:String;
    var passengers:Int;
    var baggage:Int;
    var leavingTime:Date;
    var flightNumber:String?;
    var createdOn:Date?;
    
    init(userId:String, startingPoint:String, destination:String, passengers:Int, baggage:Int, leavingTime:Date, flightNumber:String?) {
        self.id = UUID().uuidString;
        self.userId = userId;
        self.startingPoint = startingPoint;
        self.destination = destination;
        self.passengers = passengers;
        self.baggage = baggage;
        self.leavingTime = leavingTime;
        
        if (flightNumber != nil){
            self.flightNumber = flightNumber!;
        }
    }
    
    init(fromJson:[String:Any]){
        id = fromJson["id"] as! String;
        userId = fromJson["userId"] as! String;
        startingPoint = fromJson["startingPoint"] as! String;
        destination = fromJson["destination"] as! String;
        passengers = fromJson["passengers"] as! Int;
        baggage = fromJson["baggage"] as! Int;
        leavingTime = Date.fromFirebase(fromJson["leavingTime"] as! Double);
        
        if let fn = fromJson["flightNumber"] as? String {
            self.flightNumber = fn;
        }
        
        if let ts = fromJson["createdOn"] as? Double {
            self.createdOn = Date.fromFirebase(ts);
        }
    }
    
    func toJson()->[String:Any] {
        var json = [String:Any]();
        
        json["id"] = id;
        json["userId"] = userId;
        json["startingPoint"] = startingPoint;
        json["destination"] = destination;
        json["passengers"] = passengers;
        json["baggage"] = baggage;
        json["leavingTime"] = leavingTime.toFirebase();
        json["flightNumber"] = flightNumber;
        json["createdOn"] = ServerValue.timestamp();
        
        return json;
    }
}
