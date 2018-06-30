//
//  RecordWhistleViewController.swift
//  microphone
//
//  Created by Jonah Alle Monne on 22/03/2018.
//  Copyright © 2018 Jonah Alle Monne. All rights reserved.
//

import UIKit

class RecordWhistleViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "What's that Whistle?"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
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
