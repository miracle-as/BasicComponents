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


open class CoreDataFetchControllerDataSource: NSObject {

  weak fileprivate var tableView: UITableView!
  fileprivate let fetchController: NSFetchedResultsController<AnyObject>
  fileprivate let cellGenerator: (_ tableView: UITableView, _ item: AnyObject, _ indexPath: IndexPath) -> UITableViewCell?

  public init(fetchController: NSFetchedResultsController<AnyObject>, forTableView: UITableView, cellForRow: (_ tableView: UITableView, _ item: AnyObject, _ indexPath: IndexPath) -> UITableViewCell?) {

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

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchController.sections?[section].numberOfObjects ?? 0
  }


  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = fetchController.object(at: indexPath)
    return cellGenerator(tableView: tableView, item: item, indexPath: indexPath) ?? UITableViewCell()
  }
}


extension CoreDataFetchControllerDataSource: NSFetchedResultsControllerDelegate {
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }


  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }


  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                         didChange sectionInfo: NSFetchedResultsSectionInfo,
                                          atSectionIndex sectionIndex: Int,
                                                  for type: NSFetchedResultsChangeType) {

    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    default: break
    }
  }


  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                         didChange anObject: Any,
                                         at indexPath: IndexPath?,
                                                     for type: NSFetchedResultsChangeType,
                                                                   newIndexPath: IndexPath?) {

    switch (type, indexPath, newIndexPath) {
    case (.insert, _, let newIndexPath?):
      tableView.insertRows(at: [newIndexPath], with: .automatic)
    case (.delete, let indexPath?, _):
      tableView.deleteRows(at: [indexPath], with: .automatic)
    case (.update, let indexPath?, _):
      tableView.reloadRows(at: [indexPath], with: .automatic)
    case (.move, let indexPath?, let newIndexPath?):
      tableView.deleteRows(at: [indexPath], with: .automatic)
      tableView.insertRows(at: [newIndexPath], with: .automatic)
    default: break
    }
  }
}
