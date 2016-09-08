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


public class CoreDataFetchControllerDataSource: NSObject {

  weak private var tableView: UITableView!
  private let fetchController: NSFetchedResultsController
  private let cellGenerator: (tableView: UITableView, item: AnyObject, indexPath: NSIndexPath) -> UITableViewCell?

  public init(fetchController: NSFetchedResultsController, forTableView: UITableView, cellForRow: (tableView: UITableView, item: AnyObject, indexPath: NSIndexPath) -> UITableViewCell?) {

    tableView = forTableView
    self.fetchController = fetchController
    cellGenerator = cellForRow

    super.init()

    tableView.dataSource = self
    fetchController.delegate = self

    do {
      try fetchController.performFetch()
    } catch {
      let fetchError = error as NSError
      print("\(fetchError), \(fetchError.userInfo)")
    }
  }
}


extension CoreDataFetchControllerDataSource: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchController.sections?[section].numberOfObjects ?? 0
  }


  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = fetchController.objectAtIndexPath(indexPath)
    return cellGenerator(tableView: tableView, item: item, indexPath: indexPath) ?? UITableViewCell()
  }
}


extension CoreDataFetchControllerDataSource: NSFetchedResultsControllerDelegate {
  public func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }


  public func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }


  public func controller(controller: NSFetchedResultsController,
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


  public func controller(controller: NSFetchedResultsController,
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
