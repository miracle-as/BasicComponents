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

open class CoreDataManager {

	open static let sharedInstance = CoreDataManager()

	fileprivate init() {}

	public enum DataChanges {
		case deleted([NSManagedObject])
		case updated([NSManagedObject])
		case created([NSManagedObject])
	}

	open class func onDataChanges(_ block: @escaping (DataChanges) -> Void) -> NSObjectProtocol {
		return NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
			object: CoreDataManager.managedObjectContext,
			queue: OperationQueue.main) { note in
				if let updated = (note as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>  , updated.count > 0 {
					block(.updated(Array(updated)))
				}

				if let deleted = (note as NSNotification).userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> , deleted.count > 0 {
					block(.deleted(Array(deleted)))
				}

				if let inserted = (note as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> , inserted.count > 0 {
					block(.created(Array(inserted)))
				}
		}
	}


	fileprivate lazy var applicationDocumentsDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()


  fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: Application.executable, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()


	fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let storeOptions  = [NSMigratePersistentStoresAutomaticallyOption : true]
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(Application.executable).sqlite")

		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions)
		} catch {
			print("CoreData ERROR, There was an error creating or loading the application's saved data.")

			do {
        if let url = url {
          try FileManager.defaultManager().removeItemAtURL(url)
        }
				try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions)
			} catch {
				fatalError("CoreData ERROR, There was an error creating or loading the application's saved data.")
			}
		}

		return coordinator
	}()


	fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()


	fileprivate lazy var childObjectContext: NSManagedObjectContext = {
		let childObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		childObjectContext.parent = self.managedObjectContext
//		childObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return childObjectContext
	}()


	fileprivate func saveContext (_ context: NSManagedObjectContext = CoreDataManager.managedObjectContext) {
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

	open class var managedObjectContext: NSManagedObjectContext {
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

	public static func saveInMainContext(_ block: (_ context: NSManagedObjectContext) -> Void) {
		saveInMainContext(inContext: block, compleated: .none)
	}


	public static func saveInMainContext(
		inContext block: (_ context: NSManagedObjectContext) -> Void, compleated: (() -> Void)?) {
			block(CoreDataManager.managedObjectContext)
			sharedInstance.saveContext()
			if let compleated = compleated {
				compleated()
			}
	}


	public static func saveInBackgroundContext(inContext block:@escaping (_ context: NSManagedObjectContext) -> Void, compleated: @escaping () -> Void) {
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask {
//        print("Killing bgtask \(backgroundTask)")
        endBackgroundTask()
      }
//      print("Register bgtask \(backgroundTask)")
    }

    func endBackgroundTask() {
//      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = UIBackgroundTaskInvalid
    }

		let context = sharedInstance.childObjectContext
		context.perform {
      registerBackgroundTask()
			block(context)
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
			return NSStringFromClass(self).components(separatedBy: ".").last!
		}
	}


	public class func removeAllAndWait(_ inContext: NSManagedObjectContext) {
		if let entities = (try? inContext.fetch(NSFetchRequest(entityName: entityName))) as? [NSManagedObject] {
			entities.forEach(inContext.delete(_:))
		}

	}


  public class func removeAll(_ whenDone:(() -> Void)? = .none) {
    CoreDataManager.saveInBackgroundContext(
      inContext: { context in
        if let entities = (try? context.fetch(NSFetchRequest(entityName: entityName))) as? [NSManagedObject] {
          entities.forEach(context.delete(_:))
        }},
      compleated: {
        if let whenDone = whenDone {
          whenDone()
        }
      }
    )
  }


  public func saveNow(_ completed: (()->())? = .none) {
    if let context = managedObjectContext {
      if context.concurrencyType == .mainQueueConcurrencyType {
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

	public static func createEntity(_ inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
		return createEntityHelper(inContext)
	}

	fileprivate class func createEntityHelper<T: NSManagedObject>(_ inContext: NSManagedObjectContext) -> T {
		return NSEntityDescription.insertNewObject(forEntityName: entityName, into: inContext) as! T // swiftlint:disable:this force_cast
	}


	public class func findOrCreate<T: NSManagedObject>(
		whereProperty: String,
		hasValue: CVarArg,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext,
		block:((_ entity: T, _ exists: Bool) -> Void)?) -> T {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = NSPredicate(format: "%K == %@", whereProperty, hasValue)

			let entity = (try? inContext.fetch(fetchRequest).first) as? T

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
					block(entity, false)
				}
				return entity
			}
	}


	public class func countEntities(
		_ predicate: NSPredicate? = .none,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> Int {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate

    return (try? inContext.count(for: fetchRequest)) ?? 0
	}


	public class func findWhere<T: NSManagedObject>(
		_ predicate: NSPredicate? = .none,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> [T] {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate

			return (try? inContext.fetch(fetchRequest)) as? [T] ?? []
	}


  public class func findWhere<T: NSManagedObject>(
    _ predicate: String,
    inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
    ) -> [T] {

    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: predicate)

    return (try? inContext.fetch(fetchRequest)) as? [T] ?? []
  }


	public class func all<T: NSManagedObject>(_ inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [T] {
		return findWhere(inContext: inContext)
	}


	public class func fetchedResultsController (
		_ predicate: NSPredicate? = .none,
		orderBy: [NSSortDescriptor],
		sectionNameKeyPath: String? = .none,
		inContext: NSManagedObjectContext = CoreDataManager.managedObjectContext
		) -> NSFetchedResultsController<AnyObject> {

			let fetchRequest = NSFetchRequest(entityName: entityName)
			fetchRequest.predicate = predicate
			fetchRequest.sortDescriptors = orderBy

			return NSFetchedResultsController(
				fetchRequest: fetchRequest,
				managedObjectContext: inContext,
				sectionNameKeyPath: sectionNameKeyPath,
				cacheName: .none)
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
