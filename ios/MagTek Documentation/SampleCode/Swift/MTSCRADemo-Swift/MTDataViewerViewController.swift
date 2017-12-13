//
//  MTDataViewerViewController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MTDataViewerViewController: UIViewController, UITextFieldDelegate, MTSCRAEventDelegate{
    var btnConnect:UIButton?;
    var btnSendCommand:UIButton?;
    var txtData: UITextView?;
    var txtCommand:UITextField?;
    var lib: MTSCRA!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI();
        // Do any additional setup after loading the view.
    }
    func setUpUI()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Data", style: .plain, target: self, action: #selector(MTDataViewerViewController.clearData));
        
        btnConnect = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 98 - 65, width: self.view.frame.size.width, height: 50));
        btnConnect?.setTitle("Connect", for: UIControlState());
        btnConnect?.backgroundColor = UIColor(hex: 0x3465AA);
        btnConnect?.addTarget(self, action: #selector(MTDataViewerViewController.connect), for: .touchUpInside);
        
        txtData = UITextView(frame: CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 240));
        txtData?.backgroundColor = UIColor(hex: 0x667788);
        txtData?.textColor = UIColor.white;
        txtData?.isEditable = false;
        
        txtCommand = UITextField(frame: CGRect(x: 5 , y: 9, width: self.view.frame.size.width - 90, height: 40));
        txtCommand?.delegate = self;
        txtCommand?.backgroundColor = UIColor(hex: 0xdddddd);
        txtCommand?.placeholder = "Send Command";
        
        btnSendCommand = UIButton(frame: CGRect(x: (txtCommand?.frame.origin.x)! + (txtCommand?.frame.size.width)! + 5 , y: 9, width: 75, height: 40));
        btnSendCommand?.setTitle("Send", for: UIControlState());
        btnSendCommand?.addTarget(self, action: #selector(MTDataViewerViewController.sendCommand), for: .touchUpInside);
        btnSendCommand?.backgroundColor = UIColor(hex: 0x3465AA);
        
        self.view.addSubview(txtCommand!);
        self.view.addSubview(txtData!);
        self.view.addSubview(btnSendCommand!);
        self.view.addSubview(btnConnect!);
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func sendCommand()
    {
        if(txtCommand!.text?.characters.count > 0)
        {
            lib.sendcommand(withLength: txtCommand?.text);
        }
    }
    
    func connect()
    {
        if(!self.lib.isDeviceOpened())
        {
            self.txtData?.text = "Connecting";
            self.lib.openDevice();
        }
        else
        {
            self.lib.closeDevice();
            
        }
        
        
        
    }
    
    func cardSwipeDidStart(_ instance: AnyObject!) {
        DispatchQueue.main.async
            {
                self.txtData!.text = "Transfer started...";
        }
    }
    
    func cardSwipeDidGetTransError() {
        DispatchQueue.main.async
            {
                self.txtData!.text = "Transfer error...";
        }
        
    }
    
    func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: AnyObject!) {
        DispatchQueue.main.async
            {
                if((instance as! MTSCRA).isDeviceOpened())
                {
                    if(connected)
                    {
                        self.txtData?.text = "Connected...";
                        self.btnConnect?.setTitle("Disconnect", for:UIControlState());
                        self.btnConnect?.backgroundColor = UIColor(hex:0xcc3333);
                    }
                    else
                    {
                        self.txtData?.text = "Disconnected";
                        self.btnConnect?.setTitle("Connect", for:UIControlState())
                        self.btnConnect?.backgroundColor = UIColor(hex:0x3465AA);
                    }
                }
                else
                {
                    
                    self.txtData?.text = "Disconnected";
                    self.btnConnect?.setTitle("Connect", for:UIControlState())
                    
                    self.btnConnect?.backgroundColor = UIColor(hex:0x3465AA);
                }
                
        };
        
    }
    func clearData()
    {
        self.lib.clearBuffers();
        self.txtData?.text = "";
        
    }
    
    
    func onDataReceived(_ cardDataObj: MTCardData!, instance: AnyObject!) {
        DispatchQueue.main.async
            {
                self.txtData?.text = String(format: "Response.Type: %@\n\nTrack.Status: %@\n\nTrack1.Status: %@\n\nTrack2.Status: %@\n\nTrack3.Status: %@\n\nCard.Status: %@\n\nEncryption.Status: %@\n\nBattery.Level: %ld\n\nSwipe.Count: %ld\n\nTrack.Masked: %@\n\nTrack1.Masked: %@\n\nTrack2.Masked: %@\n\nTrack3.Masked: %@\n\nTrack1.Encrypted: %@\n\nTrack2.Encrypted: %@\n\nTrack3.Encrypted: %@\n\nCard.PAN: %@\n\nMagnePrint.Encrypted: %@\n\nMagnePrint.Length: %i\n\nMagnePrint.Status: %@\n\nSessionID: %@\n\nCard.IIN: %@\n\nCard.Name: %@\n\nCard.Last4: %@\n\nCard.ExpDate: %@\n\nCard.ExpDateMonth: %@\n\nCard.ExpDateYear: %@\n\nCard.SvcCode: %@\n\nCard.PANLength: %ld\n\nKSN: %@\n\nDevice.SerialNumber: %@\n\nDevice.Status: %@\n\nTLV.CARDIIN: %@\n\nMagTek SN: %@\n\nFirmware Part Number: %@\n\nTLV Version: %@\n\nDevice Model Name: %@\n\nRaw Data: \n\n\n%@", cardDataObj.responseType,
                    cardDataObj.trackDecodeStatus,
                    cardDataObj.track1DecodeStatus,
                    cardDataObj.track2DecodeStatus,
                    cardDataObj.track3DecodeStatus,
                    cardDataObj.cardStatus,
                    cardDataObj.encryptionStatus,
                    cardDataObj.batteryLevel,
                    cardDataObj.swipeCount,
                    cardDataObj.maskedTracks,
                    cardDataObj.maskedTrack1,
                    cardDataObj.maskedTrack2,
                    cardDataObj.maskedTrack3,
                    cardDataObj.encryptedTrack1,
                    cardDataObj.encryptedTrack2,
                    cardDataObj.encryptedTrack3,
                    cardDataObj.cardPAN,
                    cardDataObj.encryptedMagneprint,
                    cardDataObj.magnePrintLength,
                    cardDataObj.magneprintStatus,
                    cardDataObj.encrypedSessionID,
                    cardDataObj.cardIIN,
                    cardDataObj.cardName,
                    cardDataObj.cardLast4,
                    cardDataObj.cardExpDate,
                    cardDataObj.cardExpDateMonth,
                    cardDataObj.cardExpDateYear,
                    cardDataObj.cardServiceCode,
                    cardDataObj.cardPANLength,
                    cardDataObj.deviceKSN,
                    cardDataObj.deviceSerialNumber,
                    cardDataObj.deviceStatus,
                    cardDataObj.tagValue,
                    cardDataObj.deviceSerialNumberMagTek,
                    cardDataObj.firmware,
                    cardDataObj.tlvVersion,
                    cardDataObj.deviceName,(instance as! MTSCRA).getResponseData());
                
        }
    }
    
    func onDeviceResponse(_ data: Data!) {
        DispatchQueue.main.async
            {
                self.txtData?.text = self.txtData!.text + "\n[Transaction Result]\n\(data.hexadecimalString as String)";
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
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
