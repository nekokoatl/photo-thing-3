//  TagsViewController.swift
//  Created by Nekokoatl on 29/08/16.

import UIKit
import CoreData

class TagsViewController: UITableViewController {

    var store: PhotoStore!
    var photo: Photo!
    
    var selectedIndexPaths = [NSIndexPath]()
    
    let tagDataSource = TagDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = tagDataSource
     tableView.delegate = self
      updateTags()
    }
   
    func updateTags() {
        let tags = try! store.fetchMainQueueTags(predicate: nil,
                                                 sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        tagDataSource.tags = tags
        
     for tag in photo.tags {
            if let index = tagDataSource.tags.indexOf(tag) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                selectedIndexPaths.append(indexPath)
            }
        }
    }
    // делегат table view
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = tagDataSource.tags[indexPath.row]
        
        if let index = selectedIndexPaths.indexOf(indexPath) {
            selectedIndexPaths.removeAtIndex(index)
            photo.removeTagObject(tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addTagObject(tag)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        do {
            try store.coreDataStack.saveChanges()
        } catch let error {
            print("Core Data fail 😱: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndexPaths.indexOf(indexPath) != nil {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }

    
}