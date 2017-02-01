//
//  NewsFeedTableViewCell.swift
//  eXchange
//
//  Created by James Almeida on 4/7/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

//import UIKit
//import Firebase
//
//var ready = false
//
//class NewsFeedTableViewCell: UITableViewCell {
//    var row = 0
//    var row2 = 0
//    @IBOutlet weak var clubImage: UIImageView!
//    @IBOutlet weak var newsLabel: UILabel!
//    @IBOutlet weak var likeButton: UIButton!
//    @IBOutlet weak var likesLabel: UILabel!
//    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")
//    var hasTapped: Bool = false
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.likesLabel.text = "\u{e022}"
//        
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//        if UserDefaults.standard.object(forKey: "array") != nil
//        {
//            mealLiked = UserDefaults.standard.object(forKey: "array") as! [Bool]
//        }
//        if (ready) {
//            if (mealLiked[row]) {
//                hasTapped = true
//                likeButton.setTitle("Unlike", for: UIControlState())
//                likeButton.setTitleColor(UIColor.orange, for: UIControlState())
//            }
//            else {
//                hasTapped = false
//                likeButton.setTitle("Like", for: UIControlState())
//                likeButton.setTitleColor(UIColor.black, for: UIControlState())
//            }
//        }
//    }
//    
//    @IBAction func tapLikeButton(_ sender: UIButton) {
//        if hasTapped {
//            hasTapped = false
//            mealLiked[row] = false
//            UserDefaults.standard.set(mealLiked, forKey: "array")
//            self.likeButton.setTitle("Like", for: UIControlState())
//            self.likeButton.setTitleColor(UIColor.black, for: UIControlState())
//           // var reverseMeals = allMeals.count-currCellNum-1
//            let newsRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(row) + "/Likes")
//            let otherRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(row))
//            var likes = 0
//            newsRoot?.observeSingleEvent(of: .value, with: { snapshot in
//                let currlikes = String(describing: snapshot?.value)
//                let sketchy1 = currlikes.components(separatedBy: "(")
//                let sketchy2 = sketchy1[1].components(separatedBy: ")")
//                likes = Int(sketchy2[0])!-1
//                self.likesLabel.text = String(likes) + " \u{e022}"
//                let dict = ["Likes" : String(likes)]
//                otherRoot?.updateChildValues(dict)
//                }, withCancel: { error in
//            })
//        }
//        else {
//            hasTapped = true
//            mealLiked[row] = true
//            UserDefaults.standard.set(mealLiked, forKey: "array")
//            self.likeButton.setTitle("Unlike", for: UIControlState())
//            self.likeButton.setTitleColor(UIColor.orange, for: UIControlState())
//            //var reverseMeals = allMeals.count-currCellNum-1
//            let newsRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(row) + "/Likes")
//            let otherRoot = dataBaseRoot?.child(byAppendingPath: "newsfeed/" + String(row))
//            var likes = 0
//            newsRoot?.observeSingleEvent(of: .value, with: { snapshot in
//                let currlikes = String(describing: snapshot?.value)
//                let sketchy1 = currlikes.components(separatedBy: "(")
//                let sketchy2 = sketchy1[1].components(separatedBy: ")")
//                likes = Int(sketchy2[0])! + 1
//                self.likesLabel.text = String(likes) + " \u{e022}"
//                let dict = ["Likes" : String(likes)]
//                otherRoot?.updateChildValues(dict)
//                }, withCancel: { error in
//            })
//        }
//    }
//}

