//
//  MovieItems+CoreDataProperties.swift
//  MovieDBTask
//
//  Created by apple on 13/05/22.
//
//

import Foundation
import CoreData


extension MovieItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieItems> {
        return NSFetchRequest<MovieItems>(entityName: "MovieItems")
    }

    @NSManaged public var movieId: Int16
    @NSManaged public var movieItem: Data?
    @NSManaged public var pageNumber: Int16
    @NSManaged public var type: String?

}

extension MovieItems : Identifiable {

}
