//
//  sqlManager.swift
//  cicePractica2
//
//  Created by MAC on 4/5/21.
//

import Foundation
import SQLite3

class SqlManager {
    
    static let shared = SqlManager()
    
    private init() {}
    
    /**
     Open Database
     */
    func create(store : URL) -> OpaquePointer? {
        var db : OpaquePointer? = nil
        
        if sqlite3_open(store.absoluteString, &db) == SQLITE_OK {
            print("Ya base de datos ya existe en \(store.path)")
            return db
        }
        else {
            print("No se puede abrir la base de datos")
        }
        
        return nil
    }

    /**
     Create Table Photos
     */
    func createTable(db: OpaquePointer) {

        let tableDef = """
                        CREATE TABLE Photos(
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        filename CHAR(255) NOT NULL,
                        title CHAR(255) NOT NULL,
                        description TEXT,
                        tags CHAR(255));
                       """

        if sqlite3_exec(db, tableDef, nil, nil, nil ) == SQLITE_OK {
            print("Tabla creada")
        }
        else {
            print("Tabla ya existe")
        }
    }

    /**
     Prepare Query
    */
    func query(query : String , db: OpaquePointer , run : (OpaquePointer) -> Void) {
        var statement : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            run(statement!) //Ejecuta la funcion de callback
        }
        sqlite3_finalize(statement) //Cerramos el puntero
    }

    /**
     Insert Item
    */
    func insert(db: OpaquePointer, photo: PhotoModel) {
        
        let insertQuery : String = "INSERT INTO Photos(filename,title,description,tags) VALUES  ('\(photo.filename)','\(photo.title)','\(photo.description)','\(photo.tags)')"
        
        query(query: insertQuery, db: db){ statement in
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Photo insertada correctamente")
            }
            else {
                print("Photo NO insertada correctamente")
            }
            
        }
    }

    /**
     Count Items
    */
    func count(db: OpaquePointer) -> Int32 {
        var count : Int32 = 0
        query(query: "SELECT COUNT(*) FROM Photos", db: db) { statement in
            
            if sqlite3_step(statement) == SQLITE_ROW {
                count = sqlite3_column_int(statement, 0)
            }
            else { print("no resultados") }
        }
        return count
        
    }

    /**
     Update Items
    */
    func update(db : OpaquePointer , photo : PhotoModel) {
        
        query(query: "UPDATE Photos SET (filename,title,description,tags) = (\(photo.filename),\(photo.title),\(photo.description),\(photo.tags)", db: db) { statement in
            
            sqlite3_bind_int(statement, 1, photo.uid)
            
            if sqlite3_step(statement) == SQLITE_DONE { print("Success update") }
            else { print("Fail update") }
        }
    }

    /**
     Delete Item by Id
    */
    func delete(db : OpaquePointer , uid: Int32) {
        query(query: "DELETE FROM Photos WHERE id = \(uid)", db: db) { statement in
            if sqlite3_step(statement) == SQLITE_DONE { print("Success delete") }
            else { print("Fail delete") }
        }
    }

    
    /**
    Close Database
    */
    func close(db: OpaquePointer) {
        
        sqlite3_close(db)
    }

    /**
    Get Id Items by tag
    */
    func lookup(db : OpaquePointer, tag : String) -> [Int32] {
        var results : [Int32] = []
        
        query(query: "SELECT id FROM Photos WHERE tags LIKE '\(tag)';", db: db) { statement in
            
            var a = sqlite3_step(statement)
            
            while a == SQLITE_ROW {
                results.append(sqlite3_column_int(statement,0))
                a = sqlite3_step(statement)
            }
        }
        return results
    }
    
    /**
    Get All Items
    */
    func lookup(db : OpaquePointer) -> [PhotoModel] {
        var results : [PhotoModel] = []
        
        func sqlite3_column_swift_text(_ statement: OpaquePointer, index : Int32) -> String {
            let cstr = sqlite3_column_text(statement, index)
            if cstr != nil {
                return String(cString: cstr!)
            }
            return ""
        }
        
        query(query: "SELECT * FROM Photos", db: db) { statement in
            
            var a = sqlite3_step(statement)
            
            while a == SQLITE_ROW {
                let photo = PhotoModel(uid: sqlite3_column_int(statement, 0),
                                  filename: sqlite3_column_swift_text(statement, index: 1),
                                  title: sqlite3_column_swift_text(statement, index: 2),
                                  description: sqlite3_column_swift_text(statement, index: 3),
                                  tags: sqlite3_column_swift_text(statement, index: 4))
                results.append(photo)
                a = sqlite3_step(statement)
            }
        }
        return results
    }

    /**
    Get Item by Id
    */
    func lookup(db : OpaquePointer , uid : Int32) -> PhotoModel {
        
        func sqlite3_column_swift_text(_ statement: OpaquePointer, index : Int32) -> String {
            let cstr = sqlite3_column_text(statement, index)
            if cstr != nil {
                return String(cString: cstr!)
            }
            return ""
        }
        
        var photo : PhotoModel = PhotoModel()
        
        query(query: "SELECT * FROM Photos WHERE id=?;", db: db) { statement in
            
            sqlite3_bind_int(statement,1,uid)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                
                photo = PhotoModel(uid: sqlite3_column_int(statement, 0),
                                  filename: sqlite3_column_swift_text(statement, index: 1),
                                  title: sqlite3_column_swift_text(statement, index: 2),
                                  description: sqlite3_column_swift_text(statement, index: 3),
                                  tags: sqlite3_column_swift_text(statement, index: 4))
                
            }
            else { print("no existe el resultado") }
        }
        return photo
    }
    
    
  
    
}
