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
        datePicker.minimumDate = NSDate()
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: daysLeft,
            toDate: NSDate(),
            options: NSCalendarOptions(rawValue: 0))
        datePicker.maximumDate = endDate
        meal.text = setType
        club.text = setClub
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    @IBAction func doneButton(sender: AnyObject) {
        let pendingString = "pending/" + self.studentRequested.netid
        let pendingRoot = dataBaseRoot.childByAppendingPath(pendingString)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        let newEntry: Dictionary<String, String> = ["Date": formatter.stringFromDate(datePicker.date), "Guest": guest.netid, "Host": host.netid, "Type": setType, "Club": setClub]
        
        let newPendingRoot = pendingRoot.childByAutoId()
        
        newPendingRoot.updateChildValues(newEntry)
        
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
}


