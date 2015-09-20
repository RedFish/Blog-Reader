//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Richard Guerci on 20/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var detailViewController: DetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	var _fetchedResultsController: NSFetchedResultsController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Get access to code data
		let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context: NSManagedObjectContext = appDel.managedObjectContext
		
		let url = NSURL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?&key=AIzaSyDsDL0BoxW6aV8-1Laa8afXd9W6gUyGgTI")
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
			if error != nil {
				print("Fail dataTaskWithURL")
			} else {
				//print(NSString(data: data!, encoding: NSUTF8StringEncoding))
				do{
					let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
					if jsonResult.count > 0 { //check the result contains something
						//Fetch data to remove them all
						let request = NSFetchRequest(entityName: "Posts")
						request.returnsObjectsAsFaults = false
						do {
							let results = try context.executeFetchRequest(request)
							if results.count > 0 {
								for result in results as! [NSManagedObject] {
									context.deleteObject(result) //Delete
									do { //Save
										try context.save()
									} catch {}
								}
							}
						} catch {
							print("Fetch Failed")
						}
						
						if let items = jsonResult["items"] as? NSArray{
							for item in items{
								if let title = item["title"] as?String{
									if let content = item["content"] as?String{
										//add data to core date
										
										let newPost = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context)
										newPost.setValue(title, forKey: "title")
										newPost.setValue(content, forKey: "content")
										//Save data
										do {
											try context.save()
										} catch {
											print("Fail to save data to core data")
										}
									}
								}
							}
						}
					}
					self.tableView.reloadData()
				} catch {
					print("JSON serialization failed")
				}
				
			}
		})
		task.resume()
	}

	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = object
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}

	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		self.configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
		cell.textLabel!.text = object.valueForKey("title")!.description
	}
	
	var fetchedResultsController: NSFetchedResultsController {
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}
		
		let fetchRequest = NSFetchRequest()
		// Edit the entity name as appropriate.
		let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!)
		fetchRequest.entity = entity
		
		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20
		
		// Edit the sort key as appropriate.
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
		aFetchedResultsController.delegate = self
		_fetchedResultsController = aFetchedResultsController
		
		do {
			try _fetchedResultsController!.performFetch()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			//print("Unresolved error \(error), \(error.userInfo)")
			abort()
		}
		
		return _fetchedResultsController!
	}

	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}

}

