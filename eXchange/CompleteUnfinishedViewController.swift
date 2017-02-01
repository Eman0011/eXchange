//
//  CompleteUnfinishedViewController.swift
//  eXchange
//
//  Created by James Almeida on 4/8/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase

class CompleteUnfinishedViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
 
    @IBOutlet var meal: UILabel!
    
    @IBOutlet var club: UILabel!
    
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")

    var guest: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var host: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var studentRequested: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")

    var setType: String = ""
    var setClub: String = ""

    override func viewDidLoad() {
        datePicker.minimumDate = Date()
        let endDate = (Calendar.current as NSCalendar).date(
            byAdding: .day,
            value: daysLeft,
            to: Date(),
            options: NSCalendar.Options(rawValue: 0))
        datePicker.maximumDate = endDate
        meal.text = setType
        club.text = setClub
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    
    
    @IBAction func doneButton(_ sender: AnyObject) {
        let pendingString = "pending/" + self.studentRequested.netid
        let pendingRoot = dataBaseRoot?.child(byAppendingPath: pendingString)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        let newEntry: Dictionary<String, String> = ["Date": formatter.string(from: datePicker.date), "Guest": guest.netid, "Host": host.netid, "Type": setType, "Club": setClub]
        
        let newPendingRoot = pendingRoot?.childByAutoId()
        
        newPendingRoot?.updateChildValues(newEntry)
        
        self.dismiss(animated: true, completion: {});
    }
    
}


