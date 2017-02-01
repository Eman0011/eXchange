//
//  LaunchScreenViewController.swift
//  eXchange
//
//  Created by James Almeida on 9/26/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet var logInButton: UIButton!
    @IBOutlet var eXchangeBanner: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eXchangeBanner.image = UIImage(named:"exchange_banner")!
        
        logInButton.layer.cornerRadius = 5
        logInButton.backgroundColor = UIColor.orange
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
