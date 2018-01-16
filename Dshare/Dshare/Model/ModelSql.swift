//
//  ModelSql.swift
//  Dshare
//
//  Created by Kseniya Slobodyan on 16/01/2018.
//  Copyright © 2018 Munoz, Valentina. All rights reserved.
//

import Foundation

extension String {
    public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
        if let (result, _) = String.decodeCString(cString, as: UTF8.self,repairingInvalidCodeUnits: false) {
            self = result
        }
        else {
            return nil
        }
    }
}

class ModelSql{
    var database: OpaquePointer? = nil
    
    init?(){
        let dbFileName = "database9.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return nil
            }
        }
        
        if LastUpdateTable.createTable(database: database) == false{
            return nil
        }
    }
}
