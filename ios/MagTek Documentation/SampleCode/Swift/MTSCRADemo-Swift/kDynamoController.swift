//
//  kDynamoController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 10/3/17.
//  Copyright © 2017 MagTek. All rights reserved.
//

//import Cocoa
import UIKit
class kDynamoController: eDynamoController, UIAlertViewDelegate {
    var firstLED:UIView!;
    var secondLED:UIView!;
    var thirdLED:UIView!;
    var fourthLED:UIView!;
    var idleTimer:Timer!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Lightning EMV";
        self.lib = MTSCRA();
        
        self.lib.delegate = self;
        self.txtData?.frame =  CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 370);
        self.lib.setDeviceType(UInt32(MAGTEKKDYNAMO));
        self.lib.setDeviceProtocolString("com.magtek.idynamo")
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        self.btnConnect?.removeTarget(nil, action: nil, for: UIControlEvents.touchUpInside);
        
        self.btnConnect?.addTarget(self, action: #selector(kDynamoController.connect), for: .touchUpInside);
        addLED();
    }
    func addLED()
    {
        firstLED = UIView(frame: CGRect(x: (self.btnStartEMV?.frame.origin.x)!, y: (self.btnStartEMV?.frame.origin.y)! - 60, width: (self.btnStartEMV?.frame.size.width)!, height: (self.btnStartEMV?.frame.size.height)!));
        firstLED.backgroundColor = UIColor.gray;
        self.view.addSubview(firstLED);
        
        secondLED = UIView(frame: CGRect(x: (self.btnCancel?.frame.origin.x)!, y: (self.btnCancel?.frame.origin.y)! - 60, width: (self.btnCancel?.frame.size.width)!, height: (self.btnCancel?.frame.size.height)!));
        secondLED.backgroundColor = UIColor.gray;
        self.view.addSubview(secondLED);
        
        thirdLED = UIView(frame: CGRect(x: (self.btnReset?.frame.origin.x)!, y: (self.btnReset?.frame.origin.y)! - 60, width: (self.btnReset?.frame.size.width)!, height: (self.btnReset?.frame.size.height)!));
        thirdLED.backgroundColor = UIColor.gray;
        self.view.addSubview(thirdLED);
        
        fourthLED = UIView(frame: CGRect(x: (self.btnOptions?.frame.origin.x)!, y: (self.btnOptions?.frame.origin.y)! - 60, width: (self.btnOptions?.frame.size.width)!, height: (self.btnOptions?.frame.size.height)!));
        fourthLED.backgroundColor = UIColor.gray;
        self.view.addSubview(fourthLED);
        
    }
    func setLEDState(state:Int)
    {
        switch state
        {
            case 0:
                DispatchQueue.main.async {
                    self.firstLED.backgroundColor = .gray;
                    self.secondLED.backgroundColor = .gray;
                    self.thirdLED.backgroundColor = .gray;
                    self.fourthLED.backgroundColor = .gray;
                    self.idleTimer.invalidate();
                    self.idleTimer = nil;
            }
                break;
        case 1:
            firstLED.backgroundColor = .green;
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.firstLED.backgroundColor = .gray;
                
            })
            if #available(iOS 10.0, *) {
                idleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                    if(self.firstLED.backgroundColor == .gray)
                    {
                        self.firstLED.backgroundColor = .green;
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.firstLED.backgroundColor = .gray;
                        });
                    }
                })
            } else {
                // Fallback on earlier versions
            }
            break;
        case 2:
            DispatchQueue.main.async {
                self.firstLED.backgroundColor = .green;
            };
            break;
        case 3:
            var offsetTime = 0.0;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.firstLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.secondLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.thirdLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.fourthLED.backgroundColor = .green;
            });
           // offsetTime += 0.25;
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.setLEDState(state: 0);
            });
            
            break;
        default:
            break;
        }
    }
    func hideLED(hidden:Bool)
    {
        firstLED.isHidden = hidden;
        secondLED.isHidden = hidden;
        thirdLED.isHidden = hidden;
        fourthLED.isHidden = hidden;
    }
    
    override func startEMV() {
        super.startEMV();
        hideLED(hidden: false);
    }
    override func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: AnyObject!) {
        super.onDeviceConnectionDidChange(deviceType, connected: connected, instance: instance);
        
        
        if(deviceType == MAGTEKKDYNAMO)
        {
            if(connected)
            {
                setLEDState(state: 1);
            }
            else
            {
                setLEDState(state: 0);
            }
        }
    }
    override func OnTransactionResult(_ data: Data!) {
        super.OnTransactionResult(data);
        setLEDState(state: 0);
        setLEDState(state: 1);
        
    }
    override func OnTransactionStatus(_ data: Data!) {
        super.OnTransactionResult(data);
        
        
        let dataBytes = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt32>(start: $0, count: data.count/MemoryLayout<UInt32>.size))
        }
        
        if(dataBytes[0] == 0x04 && dataBytes[2] == 0x01)
        {
            self.setLEDState(state: 0);
            self.setLEDState(state: 2);
            
        }
        else if (dataBytes[0] == 0x09 && dataBytes[2] == 0x3c)
        {
            self.setLEDState(state: 0);
            self.setLEDState(state: 3);
        }
    }
    
    
    
    
    override func connect() {
        super.connect();
    }
}
