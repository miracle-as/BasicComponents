//
//  CoreDataManager.swift
//  Ejendomspriser
//
//  Created by Lasse Løvdahl on 21/12/2015.
//  Copyright © 2015 Miracle A/S. All rights reserved.
//

import Foundation
import CoreData
import Sugar

public class CoreDataManager {

	public static let sharedInstance = CoreDataManager()

	private init() {}

	public enum DataChanges {
		case Deleted([NSManagedObject])
		case Updated([NSManagedObject])
		case Created([NSManagedObject])
	}

	public class func onDataChanges(block: DataChanges -> Void) -> NSObjectProtocol {
		return NSNotificationCenter.defaultCenter().addObserverForName(
			NSManagedObjectContextObjectsDidChangeNotification,
			object: CoreDataManager.managedObjectContext,
			queue: NSOperationQueue.mainQueue()) { note in
				if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>  where updated.count > 0 {
					block(.Updated(Array(updated)))
				}

				if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> where deleted.count > 0 {
					block(.Deleted(Array(deleted)))
				}

				if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> where inserted.count > 0 {
					block(.Created(Array(inserted)))
				}
		}
	}


	private lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
	}()


  private lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource(Application.executable, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()


	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let storeOptions  = [NSMigratePersistentStoresAutomaticallyOption : true]
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(Application.executable).sqlite")

		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions)
		} catch {
			print("CoreData ERROR, There was an error creating or loading the application's saved data.")

			do {
        if let url = url {
          try NSFileManager.defaultManager().removeItemAtURL(url)
        }
				try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions)
			} catch {
				fatalError("CoreData ERROR, There was an error creating or loading the application's saved data.")
			}
		}

		return coordinator
	}()


	private lazy var managedObjectContext: NSManagedObjectContext = {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()


	private lazy var childObjectContext: NSManagedObjectContext = {
		let childObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		childObjectContext.parentContext = self.managedObjectContext
//		childObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return childObjectContext
	}()


	private func saveContext (context: NSManagedObjectContext = CoreDataManager.managedObjectContext) {
//		print("saving: \(context) hasChanges: \(context.hasChanges)")
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unable to save data. Error \(nserror)") //FIXME this is properly a little rough
			}
		}
	}

	public class var managedObjectContext: NSManagedObjectContext {
		return sharedInstance.managedObjectContext
	}
}


public extension NSManagedObjectContext {
  func saveIfChanged() {
    if hasChanges {
      do {
        try save()
      } catch {
        let nserror = error as NSError
        print("Unable to save data. Error \(nserror)") //FIXME this is properly a little rough
      }
    }
  }
}


public extension CoreDataManager {

	public static func saveInMainContext(@noescape block:(context: NSManagedObjectContext) -> Void) {
		saveInMainContext(inContext: block, compleated: .None)
	}


	public static func saveInMainContext(
		@noescape inContext block:(context: NSManagedObjectContext) -> Void, compleated: (() -> Void)?) {
			block(context: CoreDataManager.managedObjectContext)
			sharedInstance.saveContext()
			if let compleated = compleated {
				compleated()
			}
	}


	public static func saveInBackgroundContext(inContext block:(context: NSManagedObjectContext) -> Void, compleated: () -> Void) {
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func registerBackgroundTask() {
      backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
//        print("Killing bgtask \(backgroundTask)")
        endBackgroundTask()
      }
//      print("Register bgtask \(backgroundTask)")
    }

    func endBackgroundTask() {
//      print("Background task ended.")
      UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
      backgroundTask = UIBackgroundTaskInvalid
    }

		let context = sharedInstance.childObjectContext
		context.performBlock {
      registerBackgroundTask()
			block(context: context)
			sharedInstance.saveContext(context)
			context.reset()

			dispatch {
				sharedInstance.saveContext()
				compleated()
        endBackgroundTask()
			}
		}
	}
}


public extension NSManagedObject {


  class var entityName: String {
		get {
			return NSStringFromClass(self).componentsSeparatedByString(".").last!
		}
	}


	public class func removeAllAndWait(inContext: NSManagedObjectContext) {
		if let entities = (try? inContext.executeFetchRequest(NSFetchRequest(entityName: entityName))) as? [NSManagedObject] {
			entities.forEach(inContext.deleteObject)
		}

	}


  public class func removeAll(whenDone:(() -> Void)? = .None) {
    CoreDataManager.saveInBackgroundContext(
      inContext: { context in
        if let entities = (try? context.executeFetchRequest(NSFetchRequest(entityName: entityName))) as? [NSManagedObject] {
          entities.forEach(context.deleteObject)
        }},
      compleated: {
        if let whenDone = whenDone {
          whenDone()
        }
      }
    )
  }


  public func saveNow(completed: (()->())? = .None) {
    if let context = managedObjectContext {
      if context.concurrencyType == .MainQueueConcurrencyType {
        context.saveIfChanged()
        completed?()
      } else {
        CoreDataManager.saveInBackgroundContext(
          inContext: { context in
            context.saveIfChanged()
          },
          compleated: {
            completed?()
          }
        )
      }
    }
  }

	public static func createEntity(inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
		return createEntityHelper(inContext)
	}

	private class func createEntityHelper<T: NSManagedObject>(inContext: NSManagedObjectContext) -> T {
		return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: inContext) as! T // swiftlint:disable:this force_cast
	}


	public class func findOrCreate<T: NSManagedObject>(
		whereProperty whereProperty: String,
		hasValue: CVarArgType,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext,
		block:((entity: T, exists: Bool) -> Void)?) -> T {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = NSPredicate(format: "%K == %@", whereProperty, hasValue)

			let entity = (try? inContext.executeFetchRequest(fetchRequest).first) as? T

			if let entity = entity {
				if let block = block {
					block(entity: entity, exists: true)
				}
				return entity
			} else {
        let entity = createEntity(inContext) as! T // swiftlint:disable:this force_cast

				if let v = hasValue as? AnyObject {
					entity.setValue(v, forKeyPath: whereProperty)
				}

				if let block = block {
					block(entity: entity, exists: false)
				}
				return entity
			}
	}


	public class func countEntities(
		predicate: NSPredicate? = .None,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> Int {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate

    return (try? inContext.countForFetchRequest(fetchRequest)) ?? 0
	}


	public class func findWhere<T: NSManagedObject>(
		predicate: NSPredicate? = .None,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> [T] {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate

			return (try? inContext.executeFetchRequest(fetchRequest)) as? [T] ?? []
	}


  public class func findWhere<T: NSManagedObject>(
    predicate: String,
    inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
    ) -> [T] {

    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: predicate)

    return (try? inContext.executeFetchRequest(fetchRequest)) as? [T] ?? []
  }


	public class func all<T: NSManagedObject>(inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [T] {
		return findWhere(inContext: inContext)
	}


	public class func fetchedResultsController (
		predicate: NSPredicate? = .None,
		orderBy: [NSSortDescriptor],
		sectionNameKeyPath: String? = .None,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> NSFetchedResultsController {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = orderBy

			return NSFetchedResultsController(
				fetchRequest: fetchRequest,
				managedObjectContext: inContext,
				sectionNameKeyPath: sectionNameKeyPath,
				cacheName: .None)
	}

}


public extension String {
  public var ascending:  NSSortDescriptor {
    return NSSortDescriptor(key: self, ascending: true)
  }
  public var descending:  NSSortDescriptor {
    return NSSortDescriptor(key: self, ascending: false)
  }
}
