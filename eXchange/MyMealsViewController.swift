//
//  UserViewController.swift
//  eXchange
//
//  Created by Emanuel Castaneda on 3/20/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase

var daysLeft = 0


class MyMealsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var eXchangeBanner: UIImageView!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var unfinishedButton: UIButton!
    @IBOutlet var upcomingButton: UIButton!
    
    var historyData: [eXchange] = []
    var unfinishedData: [Meal] = []
    var upcomingData: [eXchange] = []
    var studentsData: [Student] = []
    
    
    var selectedUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var currentUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var historySelected = false
    var unfinishedSelected = true
    var upcomingSelected = false
    let formatter = DateFormatter()
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")
    var userNetID: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eXchangeBanner.image = UIImage(named:"exchange_banner")!
        self.tableView.rowHeight = 100.0
        
        unfinishedButton.layer.cornerRadius = 5
        unfinishedButton.backgroundColor = UIColor.orange
        upcomingButton.layer.cornerRadius = 5
        upcomingButton.backgroundColor = UIColor.black
        historyButton.layer.cornerRadius = 5
        historyButton.backgroundColor = UIColor.black
        
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        daysLeft = getDaysLeft()
        let tbc = self.tabBarController as! eXchangeTabBarController
        self.studentsData = tbc.studentsData
        self.userNetID = tbc.userNetID
        self.currentUser = tbc.currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadUnfinished()
        self.loadUpcoming()
        self.loadHistory()
        self.tableView.reloadData()
    }
    
    func loadHistory() {
        let path = "complete-exchange/" + userNetID
        let historyRoot = dataBaseRoot?.child(byAppendingPath: path)
        self.historyData = []
        
        historyRoot?.observe(.childAdded, with: { snapshot in
            let dict: Dictionary<String, String> = snapshot!.value as! Dictionary<String, String>
            let exchange: eXchange = self.getCompleteFromDictionary(dict)
            self.historyData.append(exchange)
            self.tableView.reloadData()
        })
    }
    
    func loadUnfinished() {
        let path = "incomplete-exchange/" + userNetID
        let unfinishedRoot = dataBaseRoot?.child(byAppendingPath: path)
        self.unfinishedData = []
        
        unfinishedRoot?.observe(.childAdded, with: { snapshot in
            let dict: Dictionary<String, String> = snapshot!.value as! Dictionary<String, String>
            let meal: Meal = self.getIncompleteFromDictionary(dict)
            let todayDate = Date()
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let todayComponents = (myCalendar as NSCalendar).components([.month], from: todayDate)
            let exchangeComponents = (myCalendar as NSCalendar).components([.month], from: self.formatter.date(from: meal.date)!)
            
            if (todayComponents.month == exchangeComponents.month) {
                self.unfinishedData.append(meal)
                self.tableView.reloadData()
            }
        })
    }
    
    func loadUpcoming() {
        let path = "upcoming/" + userNetID
        let upcomingRoot = dataBaseRoot?.child(byAppendingPath: path)
        self.upcomingData = []
        
        
        upcomingRoot?.observe(.childAdded, with: { snapshot in
            let dict: Dictionary<String, String> = snapshot!.value as! Dictionary<String, String>
            let exchange: eXchange = self.getUpcomingFromDictionary(dict)
            self.upcomingData.append(exchange)
            self.tableView.reloadData()
        })
    }
    
    
    func getCompleteFromDictionary(_ dictionary: Dictionary<String, String>) -> eXchange {
        let netID2 = dictionary["Student"]
        var student1: Student? = nil
        var student2: Student? = nil
        
        for student in studentsData {
            if (student.netid == userNetID) {
                student1 = student
            }
            if (student.netid == netID2) {
                student2 = student
            }
        }
        
        let exchange = eXchange(host: student1!, guest: student2!, type: dictionary["Type"]!)
        let mealNum1 = Meal(date: dictionary["Date1"]!, type: dictionary["Type"]!, host: student1!, guest: student2!)
        exchange.meal1 = mealNum1
        let mealNum2 = Meal(date: dictionary["Date2"]!, type: dictionary["Type"]!, host: student2!, guest: student1!)
        exchange.meal2 = mealNum2
        
        return exchange
    }
    
    func getUpcomingFromDictionary(_ dictionary: Dictionary<String, String>) -> eXchange {
        let hostID = dictionary["Host"]
        let guestID = dictionary["Guest"]
        var host: Student? = nil
        var guest: Student? = nil
        
        
        for student in studentsData {
            if (student.netid == hostID) {
                host = student
            }
            if (student.netid == guestID) {
                guest = student
            }
        }
        
        let exchange = eXchange(host: host!, guest: guest!, type: dictionary["Type"]!)
        let meal = Meal(date: dictionary["Date"]!, type: dictionary["Type"]!, host: host!, guest: guest!)
        exchange.meal1 = meal
        
        return exchange
    }
    
    func getIncompleteFromDictionary(_ dictionary: Dictionary<String, String>) -> Meal {
        let hostID = dictionary["Host"]
        let guestID = dictionary["Guest"]
        var host: Student? = nil
        var guest: Student? = nil
        
        
        for student in studentsData {
            if (student.netid == hostID) {
                host = student
            }
            if (student.netid == guestID) {
                guest = student
            }
        }
        
        let meal = Meal(date: dictionary["Date"]!, type: dictionary["Type"]!, host: host!, guest: guest!)
        
        return meal
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    
    @IBAction func upcomingButtonPressed(_ sender: AnyObject) {
        historySelected = false
        unfinishedSelected = false
        upcomingSelected = true
        upcomingButton.backgroundColor = UIColor.orange
        historyButton.backgroundColor = UIColor.black
        unfinishedButton.backgroundColor = UIColor.black
        tableView.reloadData()
    }
    @IBAction func historyButtonPressed(_ sender: AnyObject) {
        historySelected = true
        unfinishedSelected = false
        upcomingSelected = false
        historyButton.backgroundColor = UIColor.orange
        unfinishedButton.backgroundColor = UIColor.black
        upcomingButton.backgroundColor = UIColor.black
        tableView.reloadData()
    }
    
    @IBAction func unfinishedButtonPressed(_ sender: AnyObject) {
        historySelected = false
        unfinishedSelected = true
        upcomingSelected = false
        unfinishedButton.backgroundColor = UIColor.orange
        historyButton.backgroundColor = UIColor.black
        upcomingButton.backgroundColor = UIColor.black
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historySelected {
            return historyData.count
        }
        else if unfinishedSelected {
            return unfinishedData.count
        }
        else {
            return upcomingData.count
        }
    }
    
    
    /* NOTE: uses the eXchangeTableViewCell layout for simplicity. nameLabel serves as description label, and clubLabel serves as information label */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyMealsTableViewCell
        var student: Student
        if historySelected {
            unfinishedSelected = false
            upcomingSelected = false
            let exchange = historyData[(indexPath as NSIndexPath).row]
            student = exchange.guest
            cell.nameLabel.text = exchange.guest.name
            let meal2String: String
            if (exchange.meal2 == nil) {
                meal2String = "MEAL WAS NOT INITIALIZED"
            } else {
                meal2String = exchange.meal2!.date
            }
            cell.meal1Label.text = "Meal 1: \(exchange.meal1.date)"
            cell.meal2Label.text = "Meal 2: " + meal2String
        }
            
            
        else if unfinishedSelected {
            historySelected = false
            upcomingSelected = false
            let meal = unfinishedData[(indexPath as NSIndexPath).row]
            if (currentUser.netid == meal.host.netid) {
                student = meal.guest
            }
            else {
                student = meal.host
            }
            cell.nameLabel.text = "Meal eXchange with " + student.name + "."
            cell.meal1Label.text = "\(daysLeft) days left to complete!"
            cell.meal2Label.text = ""
            
            
            
        }
        else {
            historySelected = false
            unfinishedSelected = false
            let exchange = upcomingData[(indexPath as NSIndexPath).row]
            
            if (self.upcomingData[(indexPath as NSIndexPath).row].host.netid == userNetID) {
                student = exchange.guest
            } else {
                student = exchange.host
            }
            
            cell.nameLabel.text = "\(exchange.meal1.type) with \(student.name)"
            
            cell.meal1Label.text = "\(exchange.host.club) on \(exchange.meal1.date)"
            cell.meal2Label.text = ""
            
            
            
        }
        if (student.image != "") {
            let decodedData = Data(base64Encoded: student.image, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            cell.studentImage.image = UIImage(data: decodedData!)!
        } else {
            cell.studentImage.image = UIImage(named: "princetonTiger.png")
        }
        return cell
    }
    
    /* calculate the number of days left to complete meal eXchange */
    func getDaysLeft() -> Int {
        let today = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day], from: today)
        let xStart = components.day
        let range = (calendar as NSCalendar).range(of: .day, in: .month, for: today)
        let xEnd = range.length
        return xEnd - xStart!
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    override func shouldPerformSegue(withIdentifier identifier: String,sender: Any?) -> Bool {
        
        if (unfinishedSelected) {
            return true
        }
        else {
            return false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (unfinishedSelected) {
            let newViewController:CompleteUnfinishedViewController = segue.destination as! CompleteUnfinishedViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            if (self.unfinishedData[(indexPath! as NSIndexPath).row].guest.netid == currentUser.netid) {
                newViewController.host = self.unfinishedData[(indexPath! as NSIndexPath).row].guest
                newViewController.guest = self.unfinishedData[(indexPath! as NSIndexPath).row].host
                newViewController.studentRequested = self.unfinishedData[(indexPath! as NSIndexPath).row].host
            }
            else {
                newViewController.guest = self.unfinishedData[(indexPath! as NSIndexPath).row].host
                newViewController.host = self.unfinishedData[(indexPath! as NSIndexPath).row].guest
                newViewController.studentRequested = self.unfinishedData[(indexPath! as NSIndexPath).row].guest

            }
            newViewController.setType = self.unfinishedData[(indexPath! as NSIndexPath).row].type
            newViewController.setClub = self.unfinishedData[(indexPath! as NSIndexPath).row].guest.club
        }
    }
}
