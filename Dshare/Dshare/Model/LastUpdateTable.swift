
import Foundation

class LastUpdateTable{
    static let TABLE = "LAST_UPDATE"
    static let USERNAME = "USERNAME"
    static let DATE = "DATE"
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + TABLE + " ( "
            + USERNAME + " TEXT PRIMARY KEY, "
            + DATE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    static func setLastUpdate(database:OpaquePointer?, username:String, lastUpdate:Date){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO "
            + TABLE + "("
            + USERNAME + ","
            + DATE + ") VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let username = username.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, username,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 2, lastUpdate.toFirebase());
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getLastUpdateDate(database:OpaquePointer?, username:String)->Date?{
        var uDate:Date?
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from " + TABLE + " where " + USERNAME + " = ?;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            let username = username.cString(using: .utf8)
            sqlite3_bind_text(sqlite3_stmt, 1, username,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let date = Double(sqlite3_column_double(sqlite3_stmt, 1))
                uDate = Date.fromFirebase(date)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return uDate
    }
    
}
