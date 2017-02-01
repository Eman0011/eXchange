//
//  CreateRequestViewController.swift
//  eXchange
//
//  Created by James Almeida on 4/1/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase

class CreateRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var clubPicker: UIPickerView!
    @IBOutlet weak var mealTypePicker: UIPickerView!
    
    var currentUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var selectedUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var pickerData: [String] = []
    var mealTypePickerData: [String] = []

    var selectedType: String = ""
    var selectedClub: String = ""
    
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")

    
    override func viewDidLoad() {
        datePicker.minimumDate = Date()
        super.viewDidLoad()
        pickerData.append("Please select a club")
        pickerData.append(selectedUser.club)
        pickerData.append(currentUser.club)
        mealTypePickerData.append("Please select a meal")
        mealTypePickerData.append("Lunch")
        mealTypePickerData.append("Dinner")
        
        clubPicker.dataSource = self
        clubPicker.delegate = self
        mealTypePicker.dataSource = self
        mealTypePicker.delegate = self
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    
    @IBAction func doneButton(_ sender: AnyObject) {
        if ((selectedClub == selectedUser.club || selectedClub == currentUser.club) && (selectedType == "Lunch" || selectedType == "Dinner")) {
//            let selectedDate = sender.date
//            let delegate = UIApplication.shared.delegate as? AppDelegate
//            delegate?.scheduleNotification(at: selectedDate)
//            
            let pendingString = "pending/" + self.selectedUser.netid
            let pendingRoot = dataBaseRoot?.child(byAppendingPath: pendingString)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            
            var host: Student? = nil
            var guest: Student? = nil
            
            if (selectedClub == selectedUser.club) {
                host = selectedUser
                guest = currentUser
            }
            else {
                host = currentUser
                guest = selectedUser
            }
            
            let newEntry: Dictionary<String, String> = ["Date": formatter.string(from: datePicker.date), "Guest": (guest?.netid)!, "Host": (host?.netid)!, "Type": selectedType, "Club": selectedClub]
            
            let newPendingRoot = pendingRoot?.childByAutoId()
            newPendingRoot?.updateChildValues(newEntry)
            self.dismiss(animated: true, completion: {});
            
            let friendsString = "friends/" + currentUser.netid + "/"
            let friendsRoot = dataBaseRoot?.child(byAppendingPath: friendsString + selectedUser.netid)
            let otherRoot = dataBaseRoot?.child(byAppendingPath: friendsString)
            
            friendsRoot?.observeSingleEvent(of: .value, with: { snapshot in
                let num = snapshot!.value
                if (num != nil) {
                    let stringValue = String(describing: num)
                    let sketchy1 = stringValue.components(separatedBy: "(")
                    let sketchy2 = sketchy1[1].components(separatedBy: ")")
                    
                    var count = 0
                    if (sketchy2[0] == "<null>") {
                        count = 1
                    }
                    else {
                        count = Int(sketchy2[0])! + 1
                    }
                    let dict = [self.selectedUser.netid : String(describing: count)]
                    otherRoot?.updateChildValues(dict)
                }
                else {
                    let dict = [self.selectedUser.netid : String(1)]
                    otherRoot?.updateChildValues(dict)
                }
                
                }, withCancel: { error in
            })

        }
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) {
            return pickerData[row]
        }
        else {
            return mealTypePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            selectedClub = pickerData[row]
        }
        else {
            selectedType = mealTypePickerData[row]
        }
    }
    
}
