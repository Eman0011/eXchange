//
//  AccessDeniedViewController.swift
//  eXchange
//
//  Created by James Almeida on 10/18/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit

class AccessDeniedViewController: UIViewController {
    
    @IBOutlet var eXchangeBanner: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eXchangeBanner.image = UIImage(named:"exchange_banner")!
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
