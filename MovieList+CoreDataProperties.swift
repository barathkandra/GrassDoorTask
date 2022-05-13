//
//  MovieList+CoreDataProperties.swift
//  MovieDBTask
//
//  Created by apple on 13/05/22.
//
//

import Foundation
import CoreData


extension MovieList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieList> {
        return NSFetchRequest<MovieList>(entityName: "MovieList")
    }

    @NSManaged public var pageNumber: Int16
    @NSManaged public var movieItem: Data?
    @NSManaged public var movieId: Int16

}

extension MovieList : Identifiable {

}
