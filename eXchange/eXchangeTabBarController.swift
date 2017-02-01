//
//  eXchangeTabBarController.swift
//  eXchange
//
//  Created by Emanuel Castaneda on 4/6/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class eXchangeTabBarController: UITabBarController {
    var userNetID: String = ""

    var currentUser: Student = Student(name: "", netid: "", club: "", proxNumber: "", image: "")
    var studentsData: [Student] = []
    var netidToStudentMap = [String : Student] ()
    var friendsDict = [String : String]()
    var friendsData: [Student] = []
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")

    override func viewDidLoad() {
        loadStudents()
        loadFriends()
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.getFriendsFromDict()
        }
    }
    
    func loadStudents() {
        let studentsRoot = dataBaseRoot?.child(byAppendingPath: "students")
        studentsRoot?.observe(.childAdded, with:  { snapshot in
            let student = self.getStudentFromDictionary(snapshot?.value as! Dictionary<String, String>)
            self.studentsData.append(student)
            self.netidToStudentMap[student.netid] = student
        })
    }
    
    func loadFriends() {
        let friendsRoot = dataBaseRoot?.child(byAppendingPath: "friends/" + self.userNetID)
        friendsRoot?.observe(.childAdded, with:  { snapshot in
            self.friendsDict[(snapshot?.key)!] = snapshot?.value as? String
            
        })
    }
    
    func getFriendsFromDict() {
        let byValue = {
            (elem1:(key: String, val: String), elem2:(key: String, val: String))->Bool in
            if Int(elem1.val) > Int(elem2.val) {
                return true
            } else {
                return false
            }
        }
        
        let sortedDict = self.friendsDict.sorted(by: byValue)
        
        for (key, value) in sortedDict {
            let student = netidToStudentMap[key]!
            student.friendScore = Int(value)!
            friendsData.append(student)
        }
    }
    
    func getStudentFromDictionary(_ dictionary: Dictionary<String, String>) -> Student {
        let student = Student(name: dictionary["name"]!, netid: dictionary["netID"]!, club: dictionary["club"]!, proxNumber: dictionary["proxNumber"]!, image: dictionary["image"]!)

        if (student.netid == userNetID) {
            currentUser = student
        }
        
        return student
    }
}
