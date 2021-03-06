//
//  RescheduleRequestViewController.swift
//  eXchange
//
//  Created by James Almeida on 4/7/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase

var selectedClub: String = "Please select a club"
var selectedType: String = "Please select a meal"
var selectedDate: String = ""

class RescheduleRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var clubPicker: UIPickerView!
    
    @IBOutlet var mealTypePicker: UIPickerView!
    
    
    var selectedUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var currentUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var pickerData: [String] = []
    
    var mealTypePickerData: [String] = []
    
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")

    
    override func viewDidLoad() {
        selectedClub = "Please select a club"
        selectedType = "Please select a meal"
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
    
  
    @IBAction func doneButton(_ sender: AnyObject) {

    }
   

    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        selectedDate = formatter.string(from: datePicker.date)
    }
    
    
}
