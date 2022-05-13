//
//  MovieItems+CoreDataClass.swift
//  MovieDBTask
//
//  Created by apple on 13/05/22.
//
//

import Foundation
import CoreData

@objc(MovieItems)
public class MovieItems: NSManagedObject {

}

extension MovieItems {
    
    // MARK: - Inserts Feed Methods

    static func insertFeeds(_ feeds: [Movie], pageValue: Int, type: String) {
        let context = CoreDataStack.sharedInstance.managedObjectContext
        guard let entity = NSEntityDescription.entity(forEntityName: "MovieItems", in: context) else {
            return
        }

        for item in feeds {
            if let idVal = item.movieId {
                fetchFeedDataWithFeedID(idVal,type, completion: { exist in
                    if let existing = exist {
                        if existing.isEmpty {
                            let encoder = JSONEncoder()
                            do {
                                let data = try encoder.encode(item)
                                let feed = NSManagedObject(entity: entity, insertInto: context)
                                feed.setValue(idVal, forKey: "movieId")
                                feed.setValue(type, forKey: "type")
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
                            self.updateFeeds([item], pageNumber: pageValue, type)
                        }
                    }
                })
            }
        }
    }
    
    static func updateFeeds(_ feeds: [Movie], pageNumber: Int? = nil, _ type: String) {
        for item in feeds {
            if let movieId = item.movieId {
                fetchFeedDataWithFeedID(movieId,type, completion: { exist in
                    if let existing = exist {
                        if let firstFeed = existing.first {
                            self.updateFeed(existing: firstFeed, updatedFeed: item, pageNumber: pageNumber, type)

                            // deleting multiple copies if any
                            let remainingFeeds = existing.filter { $0 != firstFeed }
                            self.deleteObjects(remainingFeeds)
                        }
                    }
                })
            }
        }
    }
    
    static func updateFeed(existing: NSManagedObject, updatedFeed: Movie, pageNumber: Int? = nil,_ type: String) {
        let idVal = updatedFeed.movieId
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(updatedFeed)
            existing.setValue(data, forKey: "movieItem") // whole Feed object
            existing.setValue(idVal, forKey: "movieId")
            existing.setValue(type, forKey: "type")
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

    static func fetchFeedDataWithFeedID(_ movieId: Int,_ type: String, completion: @escaping ([MovieItems]?) -> Void) {
        let fetchRequest: NSFetchRequest<MovieItems> = MovieItems.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(movieId == %d) AND (type == %@) ", movieId,type)
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            completion(result)
        } catch let error as NSError {
            debugPrint("Error: \(error)")
            completion(nil)
        }
    }
    
    static func fetchAllFeedsAsCoreDatModels( pageNo: Int? = nil,_ type: String,completion: @escaping ([NSManagedObject]?) -> Void) {
        // let context = CoreDataStack.sharedInstance.managedObjectContext
        let fetchRequest: NSFetchRequest<MovieItems> = MovieItems.fetchRequest()
        if let page = pageNo {
            fetchRequest.predicate = NSPredicate(format: "(type == %@) AND (pageNumber == %d)", type,page)
        } else {
            fetchRequest.predicate = NSPredicate(format: "(type == %@) AND (pageNumber == %d)", type)
        }
        debugPrint("pred: \(String(describing: fetchRequest.predicate))")

        do {
            let results = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            completion(results)
        } catch {
            completion(nil)
        }
    }
    
    static func fetchFeedsWithUserID(pageNo: Int? = nil,type: String) -> [Movie] {
        var items: [Movie] = []
        fetchAllFeedsAsCoreDatModels(pageNo: pageNo,type, completion: { results in
            if let result = results {
                //use the return value
                for item in result {
                    if let data = item.value(forKey: "movieItem") as? Data {
                        let decoder = JSONDecoder()
                        do {
                            let item = try decoder.decode(Movie.self, from: data)
                            items.append(item)
                        } catch {
                            debugPrint("Error: \(error.localizedDescription)")
                        }
                    }
                }
                
            } else {
                //handle nil response
            }
        })
        
        return items
    }
}
