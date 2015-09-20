//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Richard Guerci on 20/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet weak var webView: UIWebView!
	
	var detailItem: AnyObject? {
		didSet {
			// Update the view.
			self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let detail: AnyObject = self.detailItem { //Get content after segue
			if let wv = self.webView {
				wv.loadHTMLString(detail.valueForKey("content")!.description, baseURL: nil)
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

