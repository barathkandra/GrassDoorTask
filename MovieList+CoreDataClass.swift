//
//  MovieList+CoreDataClass.swift
//  MovieDBTask
//
//  Created by apple on 13/05/22.
//
//

import Foundation
import CoreData

@objc(MovieList)
public class MovieList: NSManagedObject {

    static func saveDataContext() {
        CoreDataStack.sharedInstance.saveContext(completion: { (error) in
            if error != nil {
                debugPrint("Could not save. \(error!), \(error!.userInfo)")
            }
        })
    }
}

extension MovieList {
    
    // MARK: - Inserts Feed Methods

    static func insertFeeds(_ feeds: [Movie], pageValue: Int) {
        let context = CoreDataStack.sharedInstance.managedObjectContext
        guard let entity = NSEntityDescription.entity(forEntityName: "MovieList", in: context) else {
            return
        }

        for item in feeds {
            if let idVal = item.movieId {
                fetchFeedDataWithFeedID(idVal, completion: { exist in
                    if let existing = exist {
                        if existing.isEmpty {
                            let encoder = JSONEncoder()
                            do {
                                let data = try encoder.encode(item)
                                let feed = NSManagedObject(entity: entity, insertInto: context)
                                feed.setValue(idVal, forKey: "movieId")
                                feed.setValue(data, forKey: "movieItem")
                                feed.setValue(pageValue, forKey: "pageNumber")
                                CoreDataStack.sharedInstance.saveContext(completion: { (error) in
                                    if error != nil {
                                        debugPrint("Could not save. \(error!), \(error!.userInfo)")
                                    }
                                })

                            } catch {
                                debugPrint("Error: \(error.localizedDescription)")

                            }
                        } else {
                            self.updateFeeds([item], pageNumber: pageValue)
                        }
                    }
                })
            }
        }
    }
    
    static func updateFeeds(_ feeds: [Movie], pageNumber: Int? = nil) {
        for item in feeds {
            if let movieId = item.movieId {
                fetchFeedDataWithFeedID(movieId, completion: { exist in
                    if let existing = exist {
                        if let firstFeed = existing.first {
                            self.updateFeed(existing: firstFeed, updatedFeed: item, pageNumber: pageNumber)

                            // deleting multiple copies if any
                            let remainingFeeds = existing.filter { $0 != firstFeed }
                            self.deleteObjects(remainingFeeds)
                        }
                    }
                })
            }
        }
    }
    
    static func updateFeed(existing: NSManagedObject, updatedFeed: Movie, pageNumber: Int? = nil) {
        let idVal = updatedFeed.movieId
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(updatedFeed)
            existing.setValue(data, forKey: "movieItem") // whole Feed object
            existing.setValue(idVal, forKey: "feedID")
            if let page = pageNumber {
                existing.setValue(page, forKey: "pageNumber")
            }
            CoreDataStack.sharedInstance.saveContext(completion: { (error) in
                if error != nil {
                    debugPrint("Could not save. \(error!), \(error!.userInfo)")
                }
            })

        } catch {
            debugPrint("Error: \(error.localizedDescription)")
        }

    }
    
    static func deleteObjects(_ items: [NSManagedObject]) {
        for item in items {
            CoreDataStack.sharedInstance.managedObjectContext.delete(item)
        }
        CoreDataStack.sharedInstance.saveContext(completion: { (error) in
            if error != nil {
                debugPrint("Could not save. \(error!), \(error!.userInfo)")
            }
        })
    }
    
    // MARK: - Fetch Methods

    static func fetchFeedDataWithFeedID(_ movieId: Int, completion: @escaping ([MovieList]?) -> Void) {
        let fetchRequest: NSFetchRequest<MovieList> = MovieList.fetchRequest()
        let sort = NSSortDescriptor(key: "rowNumber", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "(userID == %@)", movieId)
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            completion(result)
        } catch let error as NSError {
            debugPrint("Error: \(error)")
            completion(nil)
        }
    }
}
