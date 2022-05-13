//
// CoreDataStack.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//


import Foundation
import UIKit
import CoreData

fileprivate struct CoreDataStackConst {
    static let resourceName = "GrassDoorTask"
    static let resourceType = "momd"
    static let persistentStore = "GrassDoorTask.sqlite"
}

class CoreDataStack: NSObject {
    
    let storeType = NSSQLiteStoreType
    let modelName: String = CoreDataStackConst.resourceName
    let persistentStore: String = CoreDataStackConst.persistentStore
    static let sharedInstance = CoreDataStack.init()
    
    override init() {
        super.init()
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(CoreDataStack.saveChanges(_:)), name: NSNotification.Name.NSExtensionHostDidEnterBackground, object: nil)
    }
    
    // MARK: - Notification Handling
    
    func saveContext(completion: @escaping (_ error: NSError?) -> () ) {
        
        managedObjectContext.perform {
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                debugPrint("Unable to Save Changes of Managed Object Context")
                debugPrint("\(saveError), \(saveError.localizedDescription)")
                completion(saveError)
                return
            }
            
            self.privateManagedObjectContext.perform {
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    debugPrint("Unable to Save Changes of Private Managed Object Context")
                    debugPrint("\(saveError), \(saveError.localizedDescription)")
                    completion(saveError)
                    return
                }
            }
        }
        completion(nil)
    }
    
    @objc func saveChanges(_ notification: NSNotification) {
        saveContext { (_) in }
    }
    
    // MARK: - Managed object contexts
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    // MARK: - Private Core Data Stack methods
    lazy private var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        if let bundle = Bundle(identifier:CoreDataBaseHandler.manager.bundleIdentifierName),
            let aPath = bundle.path(forResource: CoreDataStackConst.resourceName, ofType: CoreDataStackConst.resourceType),
            let path = URL.init(string: aPath){
            return NSManagedObjectModel(contentsOf: path)!
        }
        else {
            
            if let bundle = Bundle(identifier:CoreDataBaseHandler.manager.bundleIdentifierName),let model = NSManagedObjectModel.mergedModel(from: [bundle]){
                return model
            }
            
        }
        debugPrint("****Vader - Unable to configure CoreData Managed Object Module****")
        abort()
    }()
    
    lazy private var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var sqliteFileLocation = "\(self.persistentStore)"
        
        let options = [NSInferMappingModelAutomaticallyOption : true,
                       NSMigratePersistentStoresAutomaticallyOption : true]
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent(sqliteFileLocation)
        do {
            try coordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data." as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.sample.MovieDBTask", code: 9999, userInfo: dict)
            debugPrint("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
}
