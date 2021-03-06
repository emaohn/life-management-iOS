//
//  DisplayToDoViewController.swift
//  Koso
//
//  Created by Emmie Ohnuki on 7/27/18.
//  Copyright © 2018 Emmie Ohnuki. All rights reserved.
//

import Foundation
import UIKit

class DisplayToDoViewController: UIViewController {
    var todo: ToDo?
    var todos = [ToDo]()
    var selectedToDo: ToDo?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    @IBOutlet weak var addToDoButton: UIBarButtonItem!
    @IBOutlet weak var toDoTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.navigationBarTap))
        hideKeyboard.numberOfTapsRequired = 1
        navigationController?.navigationBar.addGestureRecognizer(hideKeyboard)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.text = todo?.title
        retrieveToDos()
        guard let deadline = todo?.deadline else {return}
        deadlineDatePicker.date = deadline
    }
    
    @objc func navigationBarTap(_ recognizer: UIGestureRecognizer) {
        view.endEditing(true)
        // OR  USE  yourSearchBarName.endEditing(true)
        
    }
    
    func retrieveToDos() {
//        todos = todo?.toDo?.allObjects as! [ToDo]
//        toDoTableView.reloadData()
        guard let myTodos = self.todo?.toDos?.allObjects as? [ToDo] else {return}
        if (myTodos.count) > 1{
            todos = myTodos.sorted(by: { (task1, task2) -> Bool in
                return task1.timeStamp! < task2.timeStamp!
            })
        }
        else{
            todos = myTodos
        }
        toDoTableView.reloadData()
    }
    
    @IBAction func addToDoButtonPressed(_ sender: UIBarButtonItem) {
        // Create the alert controller
        let alertController = UIAlertController(title: "What do you need to do?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.view.tintColor = .tcDarkGrey
        
        let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(red: 254, green: 254, blue: 254, alpha: 1)
        //title
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "ex. wash dishes"
        }
        
        // Create the actions
        let okAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let todoTextField = alertController.textFields![0] as UITextField?
            
            if todoTextField?.text != "" {
                let task = CoreDataHelper.newToDo()
        
                task.title = todoTextField?.text
                task.completed = false
                task.timeStamp = Date()

                self.todo?.addToToDos(task)
                self.retrieveToDos()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func save() {
        self.todo?.title = titleTextField.text
        self.todo?.deadline = deadlineDatePicker.date
        CoreDataHelper.saveProject()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch  identifier {
        case "saveToDo":
            save()
       case "taskBreakDown":
            save()
            guard let todo = selectedToDo else {return}
            let destination = segue.destination as? ToDoBreakdownViewController
                destination?.todo = todo
        case "cancel":
            save()
        default:
            print("error")
        }
    }

    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        CoreDataHelper.saveProject()
    }
}

extension DisplayToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell", for: indexPath) as! TaskTableViewCell
        let task = todos[indexPath.row]
        cell1.taskLabel.text = task.title
        //cell1.completionButton.adjustsImageWhenHighlighted = false
        if task.completed {
            cell1.completionButton.setTitle("[✓]", for: .normal)
        } else {
            cell1.completionButton.setTitle("[  ]", for: .normal)
        }
        cell1.completionButtonTouched = {(cell) in
            guard self.toDoTableView.indexPath(for: cell) != nil
            else { return }
            if !task.completed {
                task.completed = true
                cell1.completionButton.setTitle("[✓]", for: .normal)
            } else {
                task.completed = false
                cell1.completionButton.setTitle("[  ]", for: .normal)
            }
        }
        return cell1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedToDo = todos[indexPath.row]
        self.performSegue(withIdentifier: "taskBreakDown", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTask = todos[indexPath.row]
            CoreDataHelper.delete(todo: deletedTask)
            retrieveToDos()
        }
    }
}

extension DisplayToDoViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayToDoViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
