//
//  eDynamoController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit

class eDynamoController: MTDataViewerViewController, BLEScanListEvent, UIActionSheetDelegate{
    
    var btnStartEMV:UIButton?;
    var btnGetStatus:UIButton?;
    var userSelection:UIActionSheet?;
    var tmrTimeout:Timer?;
    var opt:optionController?;
    var btnCancel:UIButton?;
    var btnReset:UIButton?;
    var btnOptions:UIButton?;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "BLE EMV";
        self.txtData?.frame =  CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 300);
        let btnWidth = self.view.frame.size.width / 4;
        
        btnStartEMV = UIButton(frame: CGRect(x: 5, y: self.view.frame.size.height - 98 - 65 - 60, width: btnWidth - 7, height: 40));
        btnStartEMV?.setTitle("Start", for: UIControlState());
        btnStartEMV?.backgroundColor = UIColor(hex: 0x3465AA);
        btnStartEMV?.addTarget(self, action: #selector(eDynamoController.startEMV), for: .touchUpInside);
        self.view.addSubview(btnStartEMV!);
        
        btnCancel = UIButton(frame: CGRect(x: btnWidth, y: self.view.frame.size.height - 98 - 65 - 60, width: btnWidth - 2, height: 40));
        btnCancel?.setTitle("Cancel", for: UIControlState());
        btnCancel?.backgroundColor = UIColor(hex: 0xCC3333);
        btnCancel?.addTarget(self, action: #selector(eDynamoController.cancelEMV), for: UIControlEvents.touchUpInside);
        
        self.view.addSubview(btnCancel!);
        
        btnReset = UIButton(frame: CGRect(x: (btnWidth * 2), y: self.view.frame.size.height - 98 - 65 - 60, width: btnWidth - 2, height: 40));
        btnReset?.setTitle("Reset", for: UIControlState());
        btnReset?.addTarget(self, action: #selector(eDynamoController.resetDevice), for: UIControlEvents.touchUpInside);
        btnReset?.backgroundColor = UIColor(hex: 0xCC3333);
        self.view.addSubview(btnReset!);
        
        btnOptions = UIButton(frame: CGRect(x: (btnWidth * 3), y: self.view.frame.size.height - 98 - 65 - 60, width: btnWidth - 2, height: 40));
        btnOptions?.setTitle("Options", for: UIControlState());
        btnOptions?.addTarget(self, action: #selector(eDynamoController.presentOption), for: UIControlEvents.touchUpInside);
        btnOptions?.backgroundColor = UIColor(hex: 0xFF9900);
        self.view.addSubview(btnOptions!);
        
        
        
        self.lib = MTSCRA();
        self.lib.delegate = self;
        self.lib.setDeviceType(UInt32(MAGTEKEDYNAMO));
        self.btnConnect?.removeTarget(self, action: nil, for: .touchUpInside);
        self.btnConnect?.addTarget(self, action: #selector(eDynamoController.scanForBLE), for: .touchUpInside);
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        
        // Do any additional setup after loading the view.
    }
    
   
    
    func cancelEMV()
    {
        self.lib.cancelTransaction();
    }
    func resetDevice()
    {
        self.lib.sendcommand(withLength: "0200");
        
    }
    
    func presentOption()
    {
        
        if(opt == nil)
        {
            opt = optionController(style: UITableViewStyle.grouped);
        }
        self.navigationController?.pushViewController(opt!, animated: true);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectBLEReader(_ per: CBPeripheral) {
        self.lib.delegate = self;
        self.navigationController?.popViewController(animated: true);
        self.lib .setAdress(per.identifier.uuidString);
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
    
    func startEMV()
    {
        
        
        
        
        //var arr : [UInt32] = [0x3c,4,123,4,5,2];
        let timeLimit:UInt8 = 0x3c;
        let cardType:UInt8 = 0x02;
        let option :UInt8 = 0x00;
        var amount:[UInt8] = [0x00, 0x00, 0x00, 0x00, 0x15, 0x00];
        let transactionType:UInt8 = 0x00;
        var cashBack:[UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        var currencyCode:[UInt8] = [ 0x08, 0x40];
        let reportingOption:UInt8 = 0x01;
        lib.startTransaction(timeLimit, cardType: cardType, option: option, amount: &amount, transactionType: transactionType, cashBack: &cashBack, currencyCode: &currencyCode, reportingOption: reportingOption);
    }
    
    func getUserFriendlyLanguage(_ codeIn: String) -> String
    {
        let lanCode:NSDictionary = ["EN": "English","DE": "Deutsch","FR": "Français","ES": "Español","ZH": "中文","IT": "Italiano"];
        
        return lanCode.object(forKey: codeIn.uppercased()) as! String;
    }
    func OnDisplayMessageRequest(_ data: Data!) {
        if(data != nil)
        {
            let dataString = data.hexadecimalString
            
            DispatchQueue.main.async
                {
                    
                    self.txtData?.text = self.txtData!.text + ( "\n[Display Message Request]\n" +  (dataString as String).stringFromHexString);
            }
        }
    }
    func OnEMVCommandResult(_ data: Data!) {
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            self.txtData?.text = self.txtData!.text + "\n[EMV Command Result]\n\(dataString)";
            
        }
    }
    
    
    
    
    
  
    
    func OnUserSelectionRequest(_ data: Data!) {
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            
            self.txtData?.text = self.txtData!.text + "\n[User Selection Request]\n\(dataString) ";
            var dataType = [UInt8](repeating: 0, count: 1);
            //(data.subdata(in: NSMakeRange(0, 1)) as NSData).getBytes(&dataType, length: 1);
            dataType = data.subdata(in: 0 ..< 1).toArray(type: UInt8.self)
            
            var timeOut:NSInteger = 0;
            //(data.subdata(in: NSMakeRange(1, 1)) as NSData).getBytes(&timeOut, length:1);
            (data.subdata(in:  1 ..< 2) as NSData).getBytes(&timeOut, length: MemoryLayout<Int>.size)
            
            let menuItems:[String] = data.subdata(in: 2 ..< data.count - 2).hexadecimalString.components(separatedBy: "00");//.components(separatedBy: "00");
            
            self.userSelection = UIActionSheet();
            self.userSelection?.title = (menuItems[0] ).stringFromHexString;
            self.userSelection?.delegate = self;
            
            for i in 1 ..< menuItems.count - 1
            {
                if((dataType[0] & 0x01) == 1)
                {
                    self.userSelection?.addButton(withTitle: self.getUserFriendlyLanguage((menuItems[i] ).stringFromHexString));
                    
                }
                else
                {
                    self.userSelection?.addButton(withTitle: (menuItems[i] ).stringFromHexString);
                    
                }
            }
            
            self.userSelection?.destructiveButtonIndex = (self.userSelection?.addButton(withTitle: "Cancel"))!;
            self.userSelection?.show(in: self.view);
            if(timeOut > 0 )
            {
                self.tmrTimeout = Timer.scheduledTimer(timeInterval: Double(timeOut), target: self, selector: #selector(eDynamoController.selectionTimedOut), userInfo: nil, repeats: false);
                
            }
            
            
            
        }
    }
    
    func selectionTimedOut()
    {
        userSelection?.dismiss(withClickedButtonIndex: (userSelection?.destructiveButtonIndex)!, animated: true);
        self.lib.setUserSelectionResult(0x02, selection: UInt8((userSelection?.destructiveButtonIndex)! ));
        UIAlertView(title: "Transaction Timed Out", message: "User took too long to enter a selection, trasnaction has been canceled", delegate: nil, cancelButtonTitle: "Done").show();
        
    }

    
    func OnTransactionStatus(_ data: Data!) {
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            self.txtData?.text = self.txtData!.text + "\n[Transaction Status]\n\(dataString)";
            
        }
    }
    
    func OnARQCReceived(_ data: Data!) {
        let dataString = data.hexadecimalString;
        let emvByte = HexUtil.getBytesFromHexString(dataString as String);
        let tlv = (emvByte! as NSData).parseTLVData();
        
        DispatchQueue.main.async{
            self.txtData!.text = self.txtData!.text + "\n[ARQC Received]\n\(dataString)"
            
            if tlv != nil {
                let deviceSN: String = ((tlv?["DFDF25"] as AnyObject).value)!.stringFromHexString;
                self.txtData!.text = self.txtData!.text + ("\nSN Bytes = " + (tlv?["DFDF25"]! as AnyObject).value)
                self.txtData!.text = self.txtData!.text + "\nSN String = \(deviceSN)"
                let response: Data = self.buildAcquirerResponse(HexUtil.getBytesFromHexString((tlv!["DFDF25"]! as AnyObject).value),  encryptionType: HexUtil.getBytesFromHexString((tlv!["DFDF55"]! as AnyObject).value), ksn:HexUtil.getBytesFromHexString((tlv!["DFDF54"]! as AnyObject).value), approved: true )
                self.txtData!.text = self.txtData!.text + "\n[Send Respond]\n\(response.hexadecimalString)"
                self.lib.setAcquirerResponse(UnsafeMutablePointer<UInt8> (mutating: (response as NSData).bytes.bindMemory(to: UInt8.self, capacity: response.count)), length: Int32( response.count))
            }
            
        }
        
    }
    
    
    func buildAcquirerResponse(_ deviceSN: Data,  encryptionType: Data,ksn: Data, approved: Bool) ->Data
    {
        let response  = NSMutableData();
        var lenSN = 0;
        if (deviceSN.count > 0)
        {
            lenSN = deviceSN.count;
            
        }
//
        let snTagByte:[UInt8] = [0xDF, 0xdf, 0x25, UInt8(lenSN)];
        let snTag = Data(fromArray: snTagByte)
        
        var encryptLen:UInt8 = 0;
        _ = Data(bytes: &encryptLen, count: MemoryLayout.size(ofValue: encryptionType.count))
        
        let encryptionTypeTagByte:[UInt8] = [0xDF, 0xDF, 0x55, 0x01];
        let encryptionTypeTag =  Data(fromArray: encryptionTypeTagByte)
        
        var ksnLen:UInt8 = 0;
        _ = Data(bytes: &ksnLen, count: MemoryLayout.size(ofValue: encryptionType.count))
        let ksnTagByte:[UInt8] = [0xDF, 0xDF, 0x54, 0x0a];
        let ksnTag = Data(fromArray: ksnTagByte)

        let containerByte:[UInt8] = [0xFA, 0x06, 0x70, 0x04];
        let container = Data(fromArray: containerByte)
        

        
        
        
        let approvedARCByte:[UInt8] = [0x8A, 0x02, 0x30,0x30];
        let approvedARC = Data(fromArray: approvedARCByte)
//
        let declinedARCByte:[UInt8] = [0x8A, 0x02, 0x30,0x35];
        let declinedARC = Data(fromArray: declinedARCByte)
        
        let macPadding:[UInt8] = [0x00, 0x00,0x00,0x00,0x00,0x00,0x01,0x23, 0x45, 0x67];

        var len = 2 + snTag.count + lenSN + container.count + approvedARC.count ;
        
        len += encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count;
        
        var len1 = (UInt8)((len >> 8) & 0xff);
        var len2 = (UInt8)(len & 0xff);
        
        var tempByte = 0xf9;
        response.append(&len1, length: 1)
        response.append(&len2, length: 1)
        response.append(&tempByte, length: 1)

        var tempLen = encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count +  snTag.count + lenSN;
        response.append(&tempLen, length: 1);
        response.append(ksnTag);
        response.append(ksn);
        response.append(encryptionTypeTag);
        response.append(encryptionType);
        response.append(snTag);
        response.append(deviceSN);
        response.append(container);
        if(approved)
        {
            response.append(approvedARC);
        }
        else{
            response.append(declinedARC);
            
        }
        
        response.append(Data(fromArray: macPadding))
        
        return response as Data;

    }
    
 
    
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if((tmrTimeout) != nil)
        {
            tmrTimeout?.invalidate();
            tmrTimeout = nil;
            
        }
        
        
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            self.lib .setUserSelectionResult(0x01, selection: 0x00);
            return;
        }
        
        self.lib .setUserSelectionResult(0x00, selection: UInt8(buttonIndex));
        
        
        
        
    }
    
    func OnTransactionResult(_ data: Data!) {
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            self.txtData!.text = self.txtData!.text + "\n[Transaction Result]\n\(dataString)"
            //let dataString = data.subdata(in: NSMakeRange(1, data.count - 1)).hexadecimalString;
            let dataString = data.subdata(in: 1 ..< data.count - 1).hexadecimalString;
            let emvBytes = HexUtil.getBytesFromHexString(dataString as String);
            let tlv = (emvBytes! as NSData).parseTLVData();
            let dataDump = tlv?.dumpTags();
            
            //let responseTag = HexUtil.getBytesFromHexString((tlv?.object(forKey: "9F27") as! MTTLV).value);
            
            self.txtData!.text = self.txtData!.text + "\n[Parsed Transaction Result]\n " + dataDump!;
           // let sigReq = data.subdata(in: 0 ..< 1)
            
            
        }
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
