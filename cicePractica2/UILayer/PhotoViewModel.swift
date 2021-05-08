//
//  PhotoViewModel.swift
//  cicePractica2
//
//  Created by MAC on 4/5/21.
//

import UIKit
import Foundation

class PhotoViewModel {

    var photoStore : OpaquePointer!
    var photos : [PhotoModel] = []
    
    init()
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("PhotoStore.sqlite")
        
        print(fileURL)
        
        photoStore = SqlManager.shared.create(store: fileURL)
        SqlManager.shared.createTable(db: photoStore)
        
        print("\(SqlManager.shared.count(db: photoStore))")
        print("\(SqlManager.shared.lookup(db: photoStore, uid: 1).uid)")
    }
    
    func getAllPhotos() {
        photos = SqlManager.shared.lookup(db: photoStore)
    }
    
    func addPhoto(image : PhotoModel) {
        SqlManager.shared.insert(db: photoStore, photo: image)
    }
    
    func photoCount() -> Int {
        return Int(SqlManager.shared.count(db: photoStore))
    }
    
    func photo(index : Int) -> PhotoModel {
        return SqlManager.shared.lookup(db: photoStore, uid: Int32(index))
    }
    
    
    
    
}

