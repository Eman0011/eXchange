//
//  NewsFeedViewController.swift
//  eXchange
//
//  Created by Emanuel Castaneda on 3/21/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

//import UIKit
//import Firebase
//var currCellNum = 0
//var princetonButtonSelected = true
//var mealLiked = [Bool]()
//var allMeals: [Meal] = []
//
//
//class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

//    @IBOutlet var eXchangeBanner: UIImageView!
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet weak var princetonButton: UIButton!
//    @IBOutlet var myClubButton: UIButton!
//    
//    var currentUser: Student? = nil
//    
//    var filteredMeals: [Meal] = []
//    
//    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")
//    var studentsData: [Student] = []
//    
//    var userNetID: String = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        eXchangeBanner.image = UIImage(named:"exchange_banner")!
//        self.tableView.rowHeight = 100.0
//        
//        princetonButton.layer.cornerRadius = 5
//        princetonButton.backgroundColor = UIColor.orange
//        myClubButton.layer.cornerRadius = 5
//        myClubButton.backgroundColor = UIColor.black
//        
//        
//        self.loadMeals()
//        let tbc = self.tabBarController as! eXchangeTabBarController
//        self.studentsData = tbc.studentsData
//        self.userNetID = tbc.userNetID
//        self.currentUser = tbc.currentUser
//        
//        
//        let delay = 1 * Double(NSEC_PER_SEC)
//        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time) {
//           
//            // the following code reverses the newsfeed but the number of likes not reversed
//           /* var temp = [Meal]()
//            for (var i = allMeals.count-1; i>=0; i=i-1){
//                temp.append(allMeals[i])
//            }
//            allMeals = temp
//            */
//            
//            ready = true
//            for meal in allMeals {
//                if (mealLiked.count == 0) {
//                    mealLiked.append(false)
//                }
//                if (meal.host.club == self.currentUser!.club) {
//                    self.filteredMeals.append(meal)
//                }
//            }
//                if UserDefaults.standard.object(forKey: "array") != nil
//                {
//                    mealLiked = UserDefaults.standard.object(forKey: "array") as! [Bool]
//                }
//                let count1 = mealLiked.count
//                let count2 = allMeals.count
//
//                if (count1 < count2) {
//                    for i in count1...count2-1{
//                        mealLiked.append(false)
//                    }
//                }
//            if (count2 < count1) {
//                for i in count2...count1-1{
//                    mealLiked[i] = false
//                }
//            }
//                UserDefaults.standard.set(mealLiked, forKey: "array")
//            
//            self.tableView.reloadData()
//        }
//    }
//    
//    
//    override func viewWillAppear(_ animated: Bool) {
//        self.tableView.reloadData()
//    }
//    
//    func loadMeals() {
//        let mealsRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/")
//        mealsRoot?.observe(.childAdded, with: { snapshot in
//            let dict: Dictionary<String, String> = snapshot!.value as! Dictionary<String, String>
//            let meal: Meal = self.getMealFromDictionary(dict)
//            allMeals.append(meal)
//        })
//    }
//    
//    func getMealFromDictionary(_ dictionary: Dictionary<String, String>) -> Meal {
//        let netID1 = dictionary["Host"]!
//        let netID2 = dictionary["Guest"]!
//        var host: Student? = nil
//        var guest: Student? = nil
//        for student in studentsData {
//            if (student.netid == netID1) {
//                host = student
//            }
//            if (student.netid == netID2) {
//                guest = student
//            }
//        }
//        let meal = Meal(date: dictionary["Date"]!, type: dictionary["Type"]!, host: host!, guest: guest!)
//        meal.likes = Int(dictionary["Likes"]!)!
//        return meal
//    }
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // MARK: - Button Actions
//    @IBAction func princetonButtonPressed(_ sender: AnyObject) {
//        princetonButtonSelected = true
//        princetonButton.backgroundColor = UIColor.orange
//        myClubButton.backgroundColor = UIColor.black
//        tableView.reloadData()
//    }
//    
//    @IBAction func myClubButtonPressed(_ sender: AnyObject) {
//        princetonButtonSelected = false
//        myClubButton.backgroundColor = UIColor.orange
//        princetonButton.backgroundColor = UIColor.black
//        tableView.reloadData()
//    }
//    
//    // MARK: - Table view data source
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if princetonButtonSelected {
//            return allMeals.count
//        }
//        else {
//            return filteredMeals.count
//        }
//    }
//    
//    /* NOTE: uses the eXchangeTableViewCell layout for simplicity. nameLabel serves as description label, and clubLabel serves as information label */
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        var meal: Meal
//        let attrs1 = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.orange]
//        let attrs2 = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.black]
//        let attrs3 = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black]
//   
//        
//        if princetonButtonSelected {
//            currCellNum = (indexPath as NSIndexPath).row
//          // let reverseMeals = allMeals.count-currCellNum-1
//            let newsfeedRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(currCellNum))
//            let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell", for: indexPath) as! NewsFeedTableViewCell
//            cell.row = (indexPath as NSIndexPath).row
//            cell.row2 = (indexPath as NSIndexPath).row
//            cell.newsLabel?.numberOfLines = 0
//            meal = allMeals[(indexPath as NSIndexPath).row]
//            cell.clubImage?.image = UIImage(named: meal.host.club)
//            
//            newsfeedRoot?.observe(.value, with: { snapshot in
//            let count1 = mealLiked.count
//            let count2 = allMeals.count
//            
//            if (count1 < count2) {
//                for i in count1...count2-1{
//                    mealLiked.append(false)
//                }
//            }
//            if (count2 < count1) {
//                for i in count2...count1-1{
//                    mealLiked[i] = false
//                }
//            }
//            UserDefaults.standard.set(mealLiked, forKey: "array")
//            })
//            
//            var numLikes = "-1"
//            newsfeedRoot?.observeSingleEvent(of: .value, with: { snapshot in
//                var dict = snapshot?.value as! Dictionary<String, String>
//                numLikes = dict["Likes"]!
//                cell.likesLabel.text = String(numLikes) + " \u{e022}"
//            })
//            
//            let boldName1 = NSMutableAttributedString(string:meal.host.name, attributes:attrs1)
//            let boldName2 = NSMutableAttributedString(string:meal.guest.name, attributes:attrs2)
//            let boldMeal = NSMutableAttributedString(string:meal.type, attributes:attrs3)
//            
//            
//            let newsText: NSMutableAttributedString = boldName1
//            
//            newsText.append(NSMutableAttributedString(string: " and "))
//            newsText.append(boldName2)
//            newsText.append(NSMutableAttributedString(string: " eXchanged for "))
//            newsText.append(boldMeal)
//            
//            cell.newsLabel!.attributedText = newsText
//            return cell
//        }
//        else {
//            //var reverseMeals = allMeals.count-currCellNum-1
//            currCellNum = (indexPath as NSIndexPath).row
//            let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell", for: indexPath) as! NewsFeedTableViewCell
//            cell.row2 = (indexPath as NSIndexPath).row
//            for ind in 0...allMeals.count-1{
//                let meal1 = allMeals[ind]
//                let meal2 = filteredMeals[currCellNum]
//                if (meal1.date == meal2.date && meal1.type == meal2.type && meal1.guest.netid == meal2.guest.netid && meal1.host.netid == meal2.host.netid) {
//                    cell.row = ind
//                    break
//                }
//                
//            }
//            cell.newsLabel?.numberOfLines = 0
//            meal = filteredMeals[(indexPath as NSIndexPath).row]
//            cell.clubImage?.image = UIImage(named: meal.host.club)
//            let newsfeedRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(cell.row))
//            newsfeedRoot?.observe(.value, with: { snapshot in
//                let count1 = mealLiked.count
//                let count2 = allMeals.count
//                
//                if (count1 < count2) {
//                    for i in count1...count2-1{
//                        mealLiked.append(false)
//                    }
//                }
//                if (count2 < count1) {
//                    for i in count2...count1-1{
//                        mealLiked[i] = false
//                    }
//                }
//                UserDefaults.standard.set(mealLiked, forKey: "array")
//            })
//            
//            var numLikes = "-1"
//            newsfeedRoot?.observeSingleEvent(of: .value, with: { snapshot in
//                var dict = snapshot?.value as! Dictionary<String, String>
//                numLikes = dict["Likes"]!
//                cell.likesLabel.text = String(numLikes) + " \u{e022}"
//            })
//            
//            let boldName1 = NSMutableAttributedString(string:meal.host.name, attributes:attrs1)
//            let boldName2 = NSMutableAttributedString(string:meal.guest.name, attributes:attrs2)
//            let boldMeal = NSMutableAttributedString(string:meal.type, attributes:attrs3)
//            
//            let newsText: NSMutableAttributedString = boldName1
//            
//            newsText.append(NSMutableAttributedString(string: " and "))
//            newsText.append(boldName2)
//            newsText.append(NSMutableAttributedString(string: " eXchanged for "))
//            newsText.append(boldMeal)
//            
//            cell.newsLabel!.attributedText = newsText
//            
//            return cell
//        }
//    }
//    
    
// }
