//
//  eXchangeViewController.swift
//  Exchange
//
//  Created by Emanuel Castaneda on 3/18/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase

class eXchangeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    // MARK: View Controller Outlets
    
    @IBOutlet var eXchangeBanner: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var pendingButton: UIButton!
    @IBOutlet var noFriendsLabel: UILabel!
    
    // MARK: Global variable initialization
    
    // 
    var studentsData: [Student] = []
    var friendsData: [Student] = []
    var searchData: [Student] = []
    var pendingData: [Meal] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var requestSelected = true
    var rescheduleDoneButtonHit: Bool = false
    var path = -1
    var mealAtPath: Meal? = nil
    
    var userNetID: String = ""
    var currentUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var rescheduledate: String = ""
    var rescheduletype: String = ""
    var rescheduleclub: String = ""
    var rescheduleselecteduser: String = ""
    
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")
    
    
    // MARK: Initializing functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tbc = self.tabBarController as! eXchangeTabBarController
        self.userNetID = tbc.userNetID;
        
        print("Loading...")
        print("\n")
        
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.studentsData = tbc.studentsData
            self.friendsData = tbc.friendsData
            self.currentUser = tbc.currentUser
            if (self.currentUser.name == "" || self.currentUser.club == "" || self.currentUser.netid == "") {
                print("FORCE QUIT")
                //self.performSegue(withIdentifier: "forceQuit", sender: self)
                let newViewController:AccessDeniedViewController = self.storyboard?.instantiateViewController(withIdentifier: "forceQuit") as! AccessDeniedViewController
                self.present(newViewController, animated: true, completion: nil)
            }
            
            self.loadPending()
            
            self.tableView.reloadData()
            print("Done loading")
        }
        self.self.eXchangeBanner.image = UIImage(named:"exchange_banner")!
        self.tableView.rowHeight = 100.0
        self.requestButton.layer.cornerRadius = 5
        self.requestButton.backgroundColor = UIColor.orange
        self.pendingButton.layer.cornerRadius = 5
        self.pendingButton.backgroundColor = UIColor.black
        
        
        // setup search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.studentsData = []
        loadStudents()
        self.tableView.reloadData()
    }
    
    func loadPending() {
        let pendingPath = "pending/" + userNetID
        let pendingRoot = dataBaseRoot?.child(byAppendingPath: pendingPath)
        pendingRoot?.observe(.childAdded, with:  { snapshot in
            let dict: Dictionary<String, String> = snapshot!.value as! Dictionary<String, String>
            let meal: Meal = self.getPendingFromDictionary(dict)
            if !(self.pendingData.contains {$0.date == meal.date && $0.host.club == meal.host.club && $0.type == meal.type}) {
                self.pendingData.append(meal)
            }
            self.tableView.reloadData()
            }, withCancel:  { error in
        })
    }
    
    func getPendingFromDictionary(_ dictionary: Dictionary<String, String>) -> Meal {
        let netID1 = dictionary["Host"]
        let netID2 = dictionary["Guest"]
        var host: Student? = nil
        var guest: Student? = nil
        
        for student in studentsData {
            if (student.netid == netID1) {
                host = student
            }
            if (student.netid == netID2) {
                guest = student
            }
        }
        return Meal(date: dictionary["Date"]!, type: dictionary["Type"]!, host: host!, guest: guest!)
    }
    
    func loadStudents() {
        let studentsRoot = dataBaseRoot?.child(byAppendingPath: "students")
        studentsRoot?.observe(.childAdded, with:  { snapshot in
            let student = self.getStudentFromDictionary(snapshot?.value as! Dictionary<String, String>)
            self.studentsData.append(student)
            self.tableView.reloadData()
        })
    }
    
    func getStudentFromDictionary(_ dictionary: Dictionary<String, String>) -> Student {
        let student = Student(name: dictionary["name"]!, netid: dictionary["netID"]!, club: dictionary["club"]!, proxNumber: dictionary["proxNumber"]!, image: dictionary["image"]!)
        
        if (student.netid == userNetID) {
            currentUser = student
        }
        return student
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func requestButtonPressed(_ sender: AnyObject) {
        requestSelected = true
        requestButton.backgroundColor = UIColor.orange
        pendingButton.backgroundColor = UIColor.black
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.reloadData()
        
    }
    
    @IBAction func pendingButtonPressed(_ sender: AnyObject) {
        requestSelected = false
        pendingButton.backgroundColor = UIColor.orange
        requestButton.backgroundColor = UIColor.black
        
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.endEditing(true)
        self.searchController.isActive = false
        
        tableView.tableHeaderView = nil
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if requestSelected {
            if searchController.isActive && searchController.searchBar.text != "" {
                return 1
            }
            else {
                return 1
            }
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            return searchData.count
        }
        if requestSelected {
            if (section == 1) {
                return studentsData.count
            }
            else {
                if (friendsData.count == 0 && !searchController.isActive) {
                    self.noFriendsLabel.text = "You haven't exchanged with anyone yet! Search for a friend to eXchange with."
                }
                else {
                    self.noFriendsLabel.text = ""
                }
                return friendsData.count
            }
        } else {
            self.noFriendsLabel.text = ""
            return pendingData.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if requestSelected {
            if searchController.isActive && searchController.searchBar.text != "" {
                return "Princeton"
            }
                
            else {
                if (section == 1) {
                    return "Friends"
                }
                else {
                    return "Friends"
                }
            }
        }
            
        else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exchangeCell", for: indexPath) as! eXchangeTableViewCell
        var student: Student
        
        print(friendsData.count)

        // If the user has searched for another student, populate cells with matching users
        if searchController.isActive && searchController.searchBar.text != "" {
            student = searchData[(indexPath as NSIndexPath).row]
            if requestSelected {
                cell.emoji.text = ""
                cell.nameLabel.text = student.name
                cell.clubLabel.text = student.club
            }
        }
            
            // If the user is not searching, just populate cells with all appropriate groups of users
        else {
            if requestSelected {
//                if ((indexPath as NSIndexPath).section == 1) {
//                    student = studentsData[(indexPath as NSIndexPath).row]
//                    cell.emoji.text = ""
//                }
               // else {
                    student = friendsData[(indexPath as NSIndexPath).row]
                    if (friendsData.count == 0) {
                        cell.nameLabel.text = "You don't have any friends yet! Search for a friend to eXchange with."
                        print("friends data is 0, it's: ")
                        print(friendsData.count)
                    }
                    else {
                        if ((indexPath as NSIndexPath).row == 0) {
                            cell.emoji.text = "\u{e106}"
                        }
                        else if ((indexPath as NSIndexPath).row < 4) {
                            cell.emoji.text = "\u{e056}"
                        }
                        else {
                            cell.emoji.text = "\u{e415}"
                        }
                        
                        if (student.friendScore > 50) {
                            cell.emoji.text = "\u{e34a}\u{e331}\u{1F351}"
                        }
                        else if (student.friendScore > 45) {
                            cell.emoji.text = "\u{1F351}"
                        }
                        else if (student.friendScore > 40) {
                            cell.emoji.text = "\u{e34a}"
                        
                    }
                    cell.nameLabel.text = student.name
                    cell.clubLabel.text = student.club
                }
            } else {
                cell.emoji.text = ""
                if (self.pendingData[(indexPath as NSIndexPath).row].host.netid == userNetID) {
                    student = pendingData[(indexPath as NSIndexPath).row].guest
                }
                else {
                    student = pendingData[(indexPath as NSIndexPath).row].host
                }
                
                if student.name != "" {
                    let string1 = student.name + " wants to get " + pendingData[(indexPath as NSIndexPath).row].type + " at " + pendingData[(indexPath as NSIndexPath).row].host.club
                    let string2 = " on " + self.getDayOfWeekString(pendingData[(indexPath as NSIndexPath).row].date)!
                    
                    cell.nameLabel.text = string1 + string2
                    cell.clubLabel.text = ""
                }
            }
        }
        
        if (student.image != "") {
            let decodedData = Data(base64Encoded: student.image, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            cell.studentImage.image = UIImage(data: decodedData!)!
        } else {
            cell.studentImage.image = UIImage(named: "princetonTiger.png")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If the user taps on a cell in the request a meal tab, then segue to the create request view controller
        if requestSelected {
            if ((indexPath as NSIndexPath).section == 1) {
                print("tap tap tap")
                if (currentUser.club != self.studentsData[(indexPath as NSIndexPath).row].club) {
                    if (searchController.isActive && searchController.searchBar.text != "") {
                        if (currentUser.club != self.searchData[(indexPath as NSIndexPath).row].club) {
                            performSegue(withIdentifier: "createRequestSegue", sender: nil)
                        }
                    }
                    else {
                        performSegue(withIdentifier: "createRequestSegue", sender: nil)
                    }
                }
            }
            else {
                if (self.friendsData.count > 0) {
                    if (searchController.isActive && searchController.searchBar.text != "") {
                        if (currentUser.club != self.searchData[(indexPath as NSIndexPath).row].club) {
                            performSegue(withIdentifier: "createRequestSegue", sender: nil)
                        }
                    }
                    else {
                        performSegue(withIdentifier: "createRequestSegue", sender: nil)
                    }
                }
                else {
                    if (currentUser.club != self.searchData[(indexPath as NSIndexPath).row].club) {
                        if (searchController.isActive && searchController.searchBar.text != "") {
                            if (currentUser.club != self.searchData[(indexPath as NSIndexPath).row].club) {
                                performSegue(withIdentifier: "createRequestSegue", sender: nil)
                            }
                        }
                        else {
                            performSegue(withIdentifier: "createRequestSegue", sender: nil)
                        }
                    }
                }
            }
        }
            
            
            // If the user taps on a cell in the pending meals tab, then popup an alert allowing them to accept, reschedule, decline, or cancel the action
        else {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler:{ action in self.executeAction(action, indexPath:indexPath)}))
            alert.addAction(UIAlertAction(title: "Reschedule", style: .default, handler:{ action in self.executeAction(action, indexPath:indexPath)}))
            alert.addAction(UIAlertAction(title: "Decline", style: .default, handler:{ action in self.executeAction(action, indexPath:indexPath)}))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Define special actions for accept, reschedule, and decline options
    func executeAction(_ alert: UIAlertAction!, indexPath: IndexPath){
        let response = alert.title!
        
        path = (indexPath as NSIndexPath).row
        mealAtPath = pendingData[path]
        
        if (response == "Accept") {
            var found = false
            //send the exchange to the database
            let upcomingString1 = "upcoming/" + pendingData[self.path].host.netid
            let upcomingString2 = "upcoming/" + pendingData[self.path].guest.netid
            
            let upcomingRoot1 = dataBaseRoot?.child(byAppendingPath: upcomingString1)
            let upcomingRoot2 = dataBaseRoot?.child(byAppendingPath: upcomingString2)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            
            let newEntry: Dictionary<String, String> = ["Date": pendingData[self.path].date, "Guest": pendingData[self.path].guest.netid, "Host": pendingData[self.path].host.netid, "Type": pendingData[self.path].type, "Club": pendingData[self.path].host.club]
            
            let pendingString1 = "pending/" + self.currentUser.netid + "/"
            
            let pendingRootToUpdate = self.dataBaseRoot?.child(byAppendingPath: pendingString1)
            
            pendingRootToUpdate?.observe(.value, with: { snapshot in
                let children = snapshot?.children
                
                while let child = children?.nextObject() as? FDataSnapshot {
                    let childDict = child.value as! NSDictionary
                    let clubString = (childDict.value(forKey: "Club") as! NSString) as String
                    let guestString = (childDict.value(forKey: "Guest") as! NSString) as String
                    let hostString = (childDict.value(forKey: "Host") as! NSString) as String
                    let dateString = (childDict.value(forKey: "Date") as! NSString) as String
                    let typeString = (childDict.value(forKey: "Type") as! NSString) as String
                    if(clubString == self.pendingData[self.path].host.club &&
                        guestString == self.pendingData[self.path].guest.netid &&
                        hostString == self.pendingData[self.path].host.netid &&
                        dateString == self.pendingData[self.path].date &&
                        typeString == self.pendingData[self.path].type) {
                            if(!found) {
                                found = true
                                let pendingString2 = pendingString1 + String(child.key)
                                let pendingRootToRemove = self.dataBaseRoot?.child(byAppendingPath: pendingString2)
                                pendingRootToRemove?.removeValue()
                            }
                    }
                }
            });
            
            
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                let newUpcomingRoot1 = upcomingRoot1?.childByAutoId()
                let newUpcomingRoot2 = upcomingRoot2?.childByAutoId()
                
                newUpcomingRoot1?.updateChildValues(newEntry)
                newUpcomingRoot2?.updateChildValues(newEntry)
                
                //remove the request from pending requests
                self.pendingData.remove(at: self.path)
                self.tableView.reloadData()
            }
            
        }
        else if (response == "Reschedule") {
            //prompt the user to create a new exchange
            
            performSegue(withIdentifier: "rescheduleRequestSegue", sender: nil)
            
            tableView.reloadData()
        }
            
        else if (response == "Decline") {
            var found = false
            let pendingString1 = "pending/" + self.currentUser.netid + "/"
            
            let pendingRootToUpdate = self.dataBaseRoot?.child(byAppendingPath: pendingString1)
            pendingRootToUpdate?.observe(.value, with: { snapshot in
                let children = snapshot?.children
                while let child = children?.nextObject() as? FDataSnapshot {
                    let childDict = child.value as! NSDictionary
                    let clubString = (childDict.value(forKey: "Club") as! NSString) as String
                    let guestString = (childDict.value(forKey: "Guest") as! NSString) as String
                    let hostString = (childDict.value(forKey: "Host") as! NSString) as String
                    let dateString = (childDict.value(forKey: "Date") as! NSString) as String
                    let typeString = (childDict.value(forKey: "Type") as! NSString) as String
                    
                    if(clubString == self.pendingData[self.path].host.club &&
                        guestString == self.pendingData[self.path].guest.netid &&
                        hostString == self.pendingData[self.path].host.netid &&
                        dateString == self.pendingData[self.path].date &&
                        typeString == self.pendingData[self.path].type) {
                            if(!found) {
                                found = true
                                let pendingString2 = pendingString1 + String(child.key)
                                let pendingRootToRemove = self.dataBaseRoot?.child(byAppendingPath: pendingString2)
                                pendingRootToRemove?.removeValue()
                            }
                    }
                }
            });
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.pendingData.remove(at: self.path)
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    // MARK: - Search Functions
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if requestSelected {
            searchData = studentsData.filter { student in
                return student.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tableView.setContentOffset(CGPoint(x: 0, y: textField.center.y-60), animated: true)
    }
    
    
    // MARK: - Navigation
    
    @IBAction func myUnwindAction(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "unwindCancel" {
            rescheduleDoneButtonHit = false
        }
            
        else if unwindSegue.identifier == "unwindDone" {
            // create new pending request in requester's pending
            let oldHost : Student = (mealAtPath?.host)!
            let oldGuest: Student = (mealAtPath?.guest)!
            var otherUser: Student
            if (oldHost.club == currentUser.club) {
                otherUser = oldGuest
            }
            else {
                otherUser = oldHost
            }
            print("HERE")
            print(selectedClub)
            print(otherUser.club)
            print(currentUser.club)
            print(selectedType)
            if ((selectedClub == otherUser.club || selectedClub == currentUser.club) && (selectedType == "Lunch" || selectedType == "Dinner")) {
                
                let pendingString = "pending/" + otherUser.netid + "/"
                let pendingRoot = dataBaseRoot?.child(byAppendingPath: pendingString)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy"
                
                var host: Student? = nil
                var guest: Student? = nil
                
                if (selectedClub == otherUser.club) {
                    host = otherUser
                    guest = currentUser
                }
                else {
                    host = currentUser
                    guest = otherUser
                }
                
                let newEntry: Dictionary<String, String> = ["Club": selectedClub, "Date": selectedDate, "Guest": (guest?.netid)!, "Host": (host?.netid)!, "Type": selectedType]
                
                var delay = 1 * Double(NSEC_PER_SEC)
                var time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    let newPendingRoot = pendingRoot?.childByAutoId()
                    newPendingRoot?.updateChildValues(newEntry)
                }
                
                // this code removes the request from the requested user
                let pendingString1 = "pending/" + self.currentUser.netid + "/"
                
                let pendingRootToUpdate = self.dataBaseRoot?.child(byAppendingPath: pendingString1)
                pendingRootToUpdate?.observe(.value, with: { snapshot in
                    let children = snapshot?.children
                    while let child = children?.nextObject() as? FDataSnapshot {
                        let childDict = child.value as! NSDictionary
                        let clubString = (childDict.value(forKey: "Club") as! NSString) as String
                        let guestString = (childDict.value(forKey: "Guest") as! NSString) as String
                        let hostString = (childDict.value(forKey: "Host") as! NSString) as String
                        let dateString = (childDict.value(forKey: "Date") as! NSString) as String
                        let typeString = (childDict.value(forKey: "Type") as! NSString) as String
                        
                        if(clubString == self.pendingData[self.path].host.club &&
                            guestString == self.pendingData[self.path].guest.netid &&
                            hostString == self.pendingData[self.path].host.netid &&
                            dateString == self.pendingData[self.path].date &&
                            typeString == self.pendingData[self.path].type) {
                                let pendingString2 = pendingString1 + String(child.key)
                                let pendingRootToRemove = self.dataBaseRoot?.child(byAppendingPath: pendingString2)
                                pendingRootToRemove?.removeValue()
                        }
                    }
                });
                delay = 1 * Double(NSEC_PER_SEC)
                time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    //self.dismissViewControllerAnimated(true, completion: {});
                    
                    
                    //remove the request from pending requests
                    self.pendingData.remove(at: self.path)
                    self.tableView.reloadData()
                    self.rescheduleDoneButtonHit = true
                }
                
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRequestSegue" {
            let newViewController:CreateRequestViewController = segue.destination as! CreateRequestViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            if searchController.isActive && searchController.searchBar.text != "" {
                newViewController.selectedUser = self.searchData[(indexPath! as NSIndexPath).row]
                self.searchController.isActive = false
            }
            else {
                if ((indexPath as NSIndexPath?)?.section == 1) {
                    newViewController.selectedUser = self.studentsData[(indexPath! as NSIndexPath).row]
                }
                else {
                    newViewController.selectedUser = self.friendsData[(indexPath! as NSIndexPath).row]
                }
            }
            newViewController.currentUser = self.currentUser
        }
        else if segue.identifier == "rescheduleRequestSegue" {
            let newViewController:RescheduleRequestViewController = segue.destination as! RescheduleRequestViewController
            
            if (self.pendingData[path].host.netid == userNetID) {
                newViewController.selectedUser = self.pendingData[path].guest
            }
                
            else if (self.pendingData[path].guest.netid == userNetID) {
                newViewController.selectedUser = self.pendingData[path].host
            }
            newViewController.currentUser = self.currentUser
        }
//        else {
//            print("FORCE QUIT 2")
//            print(segue.identifier)
//            let destination = segue.destination as! AccessDeniedViewController
//        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func getDayOfWeekString(_ today:String)->String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.weekday, .month , .day], from: todayDate)
            let month = myComponents.month
            
            let date = myComponents.day
            let weekDay = myComponents.weekday
            var stringDay = ""
            var stringMonth = ""
            switch weekDay {
            case 1?:
                stringDay = "Sun, "
            case 2?:
                stringDay = "Mon, "
            case 3?:
                stringDay = "Tues, "
            case 4?:
                stringDay = "Wed, "
            case 5?:
                stringDay = "Thu, "
            case 6?:
                stringDay = "Fri, "
            case 7?:
                stringDay = "Sat, "
            default:
                stringDay = "Day"
            }
            
            switch month {
            case 1?:
                stringMonth = "January "
            case 2?:
                stringMonth = "February "
            case 3?:
                stringMonth = "March "
            case 4?:
                stringMonth = "April "
            case 5?:
                stringMonth = "May "
            case 6?:
                stringMonth = "June "
            case 7?:
                stringMonth = "July "
            case 8?:
                stringMonth = "August "
            case 9?:
                stringMonth = "September "
            case 10?:
                stringMonth = "October "
            case 11?:
                stringMonth = "November "
            case 12?:
                stringMonth = "December "
                
            default:
                stringDay = "Month"
            }
            let stringValue = String(describing: date)
            let sketchy1 = stringValue.components(separatedBy: "(")
            let sketchy2 = sketchy1[1].components(separatedBy: ")")
            return stringDay + stringMonth + sketchy2[0]
        } else {
            return nil
        }
    }
}

