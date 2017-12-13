//
//  DynaMAXController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit

class DynaMAXController: MTDataViewerViewController, BLEScanListEvent {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lib = MTSCRA();
        self.lib.delegate = self;
        self.lib.setDeviceType(UInt32(MAGTEKDYNAMAX));
        self.btnConnect?.removeTarget(self, action: nil, for: .touchUpInside);
        self.btnConnect?.addTarget(self, action: #selector(DynaMAXController.scanForBLE), for: .touchUpInside);
        // Do any additional setup after loading the view.
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didSelectBLEReader(_ per: CBPeripheral) {
        self.lib.delegate = self;
        self.navigationController?.popViewController(animated: true);
        self.lib .setUUIDString(per.identifier.uuidString);
        self.lib.openDevice();
    }

    func scanForBLE()
    {
        if(self.lib.isDeviceOpened())
        {
            self.lib.closeDevice();
            
            return;
            
        }
        
        let list = BLEScannerList(style: .plain, lib: lib);
        list.delegate = self;
        self.navigationController?.pushViewController(list, animated: true);
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
