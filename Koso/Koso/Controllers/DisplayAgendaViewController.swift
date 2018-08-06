//
//  DisplayAgendaViewController.swift
//  Koso
//
//  Created by Emmie Ohnuki on 7/27/18.
//  Copyright © 2018 Emmie Ohnuki. All rights reserved.
//

import Foundation
import UIKit

class DisplayAgendaViewController: UIViewController {
    var agenda: Agenda?
    var plans = [Plan]() {
        didSet {
            planTableView.reloadData()
        }
    }
    
    var selectedPlan: Plan?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var timePeriodTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var planTableView: UITableView!
    
    @IBOutlet weak var addPlanButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planTableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //planTableView.keyboardDismissMode = .interactive
        reloadPlans()
        setup()
    }
    
    func setup() {
        startTimeTextField.text = agenda?.start
        timePeriodTextField.text = agenda?.timeInterval
        endTimeTextField.text = agenda?.end
    }
    
//    func createNewPlan(){
//        let plan = CoreDataHelper.newPlan()
//        plan.title = ""
//        plan.details = ""
//        plan.endTime = ""
//        plan.startTime = ""
//        plan.timeStamp = Date()
//        plan.location = ""
//        agenda?.addToPlan(plan)
//
//    }
    @IBAction func addPlanButtonPressed(_ sender: UIBarButtonItem) {
        // Create the alert controller
        let alertController = UIAlertController(title: "New Plan", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(red: 201/255, green: 200/255, blue: 209/255, alpha: 1)
        //title
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Title"
            
        }
        //location
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Location"
        }
        //start
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Start Time/Date"
        }
        //end
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter End Time/Date"
        }
    
        // Create the actions
        let okAction = UIAlertAction(title: "ADD", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let title = alertController.textFields![0] as UITextField?
            let location = alertController.textFields![1] as UITextField?
            let start = alertController.textFields![2] as UITextField?
            let end = alertController.textFields![3] as UITextField?
            
            let plan = CoreDataHelper.newPlan()
            plan.title = title?.text
            plan.location = location?.text
            plan.startTime = start?.text
            plan.endTime = end?.text
            plan.timeStamp = Date()
            
            self.agenda?.addToPlan(plan)
            self.reloadPlans()
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
    
    func reloadPlans() {
//        plans = (agenda?.plan?.allObjects as? [Plan])!
        guard let myPlans = agenda?.plan?.allObjects as? [Plan] else {return}
        if (myPlans.count) > 1 {
            plans = myPlans.sorted(by: { (plan1, plan2) -> Bool in
                return plan1.timeStamp! < plan2.timeStamp!
            })
        } else{
            plans = myPlans
        }
        planTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "save":
            agenda?.timeInterval = timePeriodTextField.text
            agenda?.start = startTimeTextField.text
            agenda?.end = endTimeTextField.text
            CoreDataHelper.saveProject()
        case "editPlan":
            let destination = segue.destination as? DisplayPlanViewController
            destination?.plan = self.selectedPlan
        case "cancel":
            print("cancel")
        default:
            print("error")
        }
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        CoreDataHelper.saveProject()
    }
}
extension DisplayAgendaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (plans.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "planTableViewCell", for: indexPath) as! PlanTableViewCell
        let plan = plans[indexPath.row]
        cell.titleLabel.text = plan.title
        cell.detailsTextView.text = plan.details
        cell.startLabel.text = plan.startTime
        cell.endLabel.text = plan.endTime
        cell.locationLabel.text = plan.location
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlan = plans[indexPath.row]
        self.performSegue(withIdentifier: "editPlan", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedPlan = plans[indexPath.row]
            CoreDataHelper.delete(plan: deletedPlan)
            plans = agenda?.plan?.allObjects as! [Plan]
        }
    }
}

extension DisplayAgendaViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayAgendaViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

