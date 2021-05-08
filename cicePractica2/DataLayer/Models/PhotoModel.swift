//
//  PhotoModel.swift
//  cicePractica2
//
//  Created by MAC on 4/5/21.
//

import Foundation

struct PhotoModel {
    
    var uid : Int32 //id base de datos
    var filename : String //url del archivo de foto (jpg)
    var title : String //titulo definido por el usuario
    var description : String //descripvion de la foto por el usuario
    var tags : String
    
    init(uid : Int32 = -1,
         filename : String = "",
         title : String = "" ,
         description : String = "",
         tags: String = "")
    {
        
        self.uid = uid
        self.filename = filename
        self.title = title
        self.description = description
        self.tags = tags
        
    }
}
