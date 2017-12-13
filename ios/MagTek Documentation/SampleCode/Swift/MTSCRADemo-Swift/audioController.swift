//
//  audioController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit

class audioController: MTDataViewerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Audio"
        self.lib  = MTSCRA();
        self.lib.delegate = self;
        self.lib.setDeviceType(UInt32(MAGTEKAUDIOREADER));
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
