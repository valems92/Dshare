import Foundation

class Search {
    var id:String;
    var userId:String;
    var startingPoint:String;
    var destination:String;
    var passengers:Int;
    var baggage:Int;
    
    init(userId:String, startingPoint:String, destination:String, passengers:Int, baggage:Int) {
        self.id = UUID().uuidString;
        self.userId = userId;
        self.startingPoint = startingPoint;
        self.destination = destination;
        self.passengers = passengers;
        self.baggage = baggage;
    }
    
    init(fromJson:[String:Any]){
        id = fromJson["id"] as! String;
        userId = fromJson["userId"] as! String;
        startingPoint = fromJson["startingPoint"] as! String;
        destination = fromJson["destination"] as! String;
        passengers = fromJson["passengers"] as! Int;
        baggage = fromJson["baggage"] as! Int;
    }
    
    func toJson()->[String:Any] {
        var json = [String:Any]();
        
        json["id"] = id;
        json["userId"] = userId;
        json["startingPoint"] = startingPoint;
        json["destination"] = destination;
        json["passengers"] = passengers;
        json["baggage"] = baggage;
        
        return json;
    }
}
