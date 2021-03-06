//
//  ProjectManagerViewController.swift
//  Koso
//
//  Created by Emmie Ohnuki on 7/24/18.
//  Copyright © 2018 Emmie Ohnuki. All rights reserved.
//

import Foundation
import UIKit

class ProjectManagerViewController: UIViewController {
    var projects = [Project]() {
        didSet {
            projectTableView.reloadData()
        }
    }
    
    @IBOutlet weak var projectTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.navigationBarTap))
        hideKeyboard.numberOfTapsRequired = 1
        navigationController?.navigationBar.addGestureRecognizer(hideKeyboard)
    }
    
    @objc func navigationBarTap(_ recognizer: UIGestureRecognizer) {
        view.endEditing(true)
        // OR  USE  yourSearchBarName.endEditing(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        projects = CoreDataHelper.retrieveProjects()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        
        switch identifier {
        case "newProject":
            print("creating new project")
            
        case "openProject":
            print("opening project")
            guard let indexPath = projectTableView.indexPathForSelectedRow else {return}
            let project = projects[indexPath.row]
            let destination = segue.destination as? DisplayProjectViewController
            destination?.project = project
            
        default:
            print("Error")
        }
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        projects = CoreDataHelper.retrieveProjects()
    }
}
extension ProjectManagerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingProject", for: indexPath) as! ProjectTableviewCell
        let project = projects[indexPath.row]
        cell.titleLabel.text = project.name
        cell.dueDateLabel.text = "Due " + (project.dueDate?.convertToString())!
        if let numDaysLeft = project.dueDate?.interval(ofComponent: .day, fromDate: Date()) {
            cell.numDaysLeftLabel.text = "\(numDaysLeft)"
        }
        cell.projectDescriptionLabel.text = project.projectDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openProject", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedProject = projects[indexPath.row]
            CoreDataHelper.delete(project: deletedProject)
            projects = CoreDataHelper.retrieveProjects()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
