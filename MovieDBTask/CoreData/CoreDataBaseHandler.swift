//
//  CoreDataBaseHandler.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//


import Foundation

public class CoreDataBaseHandler {
    
    let bundleIdentifierName: String = Bundle.main.bundleIdentifier ?? "com.sample.MovieDBTask"
    
    var bundleIdentifier: String {
        get {
            return bundleIdentifierName
        }
    }
        
    struct StaticObject {
        static var instance : CoreDataBaseHandler?
    }
    
    public class var manager: CoreDataBaseHandler {
        if StaticObject.instance == nil {
            StaticObject.instance = CoreDataBaseHandler()
        }
        return StaticObject.instance!
    }
    
    init() {

    }
}
