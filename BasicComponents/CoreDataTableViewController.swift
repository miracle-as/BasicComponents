//
//  CoreDataTableViewController.swift
//  Ejendomspriser
//
//  Created by Lasse Løvdahl on 13/01/2016.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public protocol CoreDataTableViewController: UITableViewDataSource, NSFetchedResultsControllerDelegate {
  var fetchedResultsController: NSFetchedResultsController { get }
  weak var tableView: UITableView! { get }
}

// MARK:- UITableViewDataSource
extension CoreDataTableViewController {
  private var _fetchedResultsController: NSFetchedResultsController {
    if fetchedResultsController.fetchedObjects == nil {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        let fetchError = error as NSError
        print("\(fetchError), \(fetchError.userInfo)")
      }
    }
    return fetchedResultsController
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return _fetchedResultsController.sections?.count ?? 0
  }


  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }
}

// MARK:- NSFetchedResultsControllerDelegate
extension CoreDataTableViewController {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }


  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }


  func controller(controller: NSFetchedResultsController,
                  didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                   atIndex sectionIndex: Int,
                                           forChangeType type: NSFetchedResultsChangeType) {

    switch type {
    case .Insert:
      tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    case .Delete:
      tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    default: break
    }
  }


  func controller(controller: NSFetchedResultsController,
                  didChangeObject anObject: AnyObject,
                                  atIndexPath indexPath: NSIndexPath?,
                                              forChangeType type: NSFetchedResultsChangeType,
                                                            newIndexPath: NSIndexPath?) {

    switch (type, indexPath, newIndexPath) {
    case (.Insert, _, let newIndexPath?):
      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
    case (.Delete, let indexPath?, _):
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    case (.Update, let indexPath?, _):
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    case (.Move, let indexPath?, let newIndexPath?):
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
    default: break
    }
  }
}

//class CoreDataTableViewWWController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
//  lazy var fetchedResultsController: NSFetchedResultsController = self.initFetchedResultsController()
//
//
//  func initFetchedResultsController() -> NSFetchedResultsController {
//    return NSFetchedResultsController()
//  }
//
//  @IBOutlet weak var tableView: UITableView!
//
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    do {
//      try fetchedResultsController.performFetch()
//    } catch {
//      let fetchError = error as NSError
//      print("\(fetchError), \(fetchError.userInfo)")
//    }
//  }
//
//
//
//}
