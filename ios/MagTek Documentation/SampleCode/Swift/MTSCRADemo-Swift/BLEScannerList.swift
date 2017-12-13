//
//  BLEScannerList.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit


protocol BLEScanListEvent {
    
    func didSelectBLEReader(_ per: CBPeripheral);

}

class BLEScannerList: UITableViewController, MTSCRAEventDelegate {
    var lib:MTSCRA?;
    var deviceList:NSMutableArray!;
    var delegate: BLEScanListEvent?;
 
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    init(style: UITableViewStyle, lib:MTSCRA) {
        super.init(style: style);
        self.lib = lib
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(lib != nil)
        {
            lib?.delegate = self;
            deviceList = NSMutableArray();
            let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.lib?.startScanningForPeripherals();
                
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad();
        self.tableView.delegate = self;
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell");
    }
    
    func bleReaderDidDiscoverPeripheral()
    {
        deviceList = lib?.getDiscoveredPeripherals();
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(deviceList == nil) {return 0;}
        return deviceList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath);
        cell.textLabel?.text = (deviceList?.object(at: indexPath.row) as! CBPeripheral).name;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lib?.stopScanningForPeripherals();
        self.delegate?.didSelectBLEReader(self.deviceList?.object(at: indexPath.row) as! CBPeripheral)
    }
   
    
    

}
