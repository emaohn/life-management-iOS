//
//  AddElements.swift
//  Koso
//
//  Created by Emmie Ohnuki on 7/25/18.
//  Copyright © 2018 Emmie Ohnuki. All rights reserved.
//

import Foundation
import UIKit

class AddElementsViewController: UIViewController {
    var selectedElement: Element?
    
    @IBOutlet weak var addToDoButton: UIButton!
    @IBOutlet weak var addListButton: UIButton!
    @IBOutlet weak var addAgendaButton: UIButton!
    @IBOutlet weak var addNoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addToDoButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "createToDo", sender: self)
    }
    
    @IBAction func addListButtonPressed(_ sender: UIButton) {
        selectedElement = CoreDataHelper.newImage()
        let photoHelper = PhotoHelper()
        photoHelper.presentActionSheet(from: self)
        self.performSegue(withIdentifier: "backToDisplayProject", sender: self)
    }
    
    @IBAction func addAgendaButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "createAgenda", sender: self)    }
    
    @IBAction func addNoteButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "createNote", sender: self)
    }
    
//    @IBAction func cancelNewElementButtonPressed(_ sender: Any) {
//        self.performSegue(withIdentifier: "cancel", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        
        switch identifier {
        case "backToDisplayProject":
            let destination = segue.destination as? DisplayProjectViewController
            if let element = selectedElement {
                element.timeStamp = Date()
                destination?.project?.addToElement(element)
                CoreDataHelper.saveProject()
            } else { return }
        case "createToDo":
            let destination = segue.destination as? DisplayToDoViewController
            let todo = CoreDataHelper.newToDo()
            todo.timeStamp = Date()
            destination?.todo = todo
        case "createNote":
            let destination = segue.destination as? DisplayNoteViewController
            let note = CoreDataHelper.newNote()
            note.timeStamp = Date()
            destination?.note = note
        case "createAgenda":
            let destination = segue.destination as? DisplayAgendaViewController
            let agenda = CoreDataHelper.newAgenda()
            agenda.timeStamp = Date()
            destination?.agenda = agenda
        case "cancel":
            print("canceling")
        default:
            print("error")
        }
    }
    
}
