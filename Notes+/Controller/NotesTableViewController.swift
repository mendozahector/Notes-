//
//  NotesTableViewController.swift
//  Notes+
//
//  Created by Hector Mendoza on 9/4/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Selected row
    }

}
