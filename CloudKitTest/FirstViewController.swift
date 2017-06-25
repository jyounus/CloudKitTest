//
//  FirstViewController.swift
//  CloudKitTest
//
//  Created by Junaid Younus on 25/06/2017.
//  Copyright © 2017 Junaid Younus. All rights reserved.
//
//  Findings:
//
//  -fetchId() works without having to request for any permissions.
//  -fetchId() returns the same id even if the user deletes the app and reinstalls it. The only time it changes is when the
//  app id changes or if the user signs into a different iCloud account.
//
//  Everything other than fetchId(), updatePermissionStatus() and updateAccountStatus() requires permissions,
//  so probably not worth it to automagically fetch user's first/last name.
//  -fetchUserDetails() doesn't seem to return the phone number/email address associated to my iCloud account, only the nameComponents object has some data in it.
//
//  If fetchId() succeeds, pass that to the API. On the API side, update it to take the id in the token and use it that way.
//  If no iCloud account is available, think of a fallback method. Either prompt the user to go into Settings and sign in (not the best) OR think
//  of something else ie use their phone number/email/social network login?
//
//  Probably best to tell user to sign in, because the app will require an active in-app subscription anyway... so no point of a fallback alternative.
//

import UIKit
import CloudKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var accountStatusLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var userDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updatePermissionStatus()
        updateAccountStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUpdatePermissionPressed(_ sender: Any) {
        updatePermissionStatus()
    }
    
    @IBAction func onUpdateAccountPressed(_ sender: Any) {
        updateAccountStatus()
    }
    
    @IBAction func onRequestPermissionsPressed(_ sender: Any) {
        requestPermissions()
    }
    
    @IBAction func onFetchIdPressed(_ sender: Any) {
        fetchId()
    }
    
    @IBAction func onFetchUserDetailsPressed(_ sender: Any) {
        fetchUserDetails()
    }
    
    func updatePermissionStatus() {
        let container = CKContainer.default()
        
        container.status(forApplicationPermission: .userDiscoverability) {
            (status: CKApplicationPermissionStatus, error: Error?) in
            
            var statusText = "unknown"
            if status == .initialState {
                statusText = "initialState"
            } else if status == .couldNotComplete {
                statusText = "couldNotComplete"
            } else if status == .denied {
                statusText = "denied"
            } else if status == .granted {
                statusText = "granted"
            }
            
            if let error = error {
                statusText = "Error: \(error)"
            }
            
            DispatchQueue.main.async {
                self.permissionLabel.text = "Permission status: \(statusText)"
            }
        }
    }
    
    func fetchId() {
        let container = CKContainer.default()
        
        container.fetchUserRecordID { (record: CKRecordID?, error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self.idLabel.text = "iCloud id error: \(error)"
                    
                } else if let record = record {
                    self.idLabel.text = "iCloud id: \(record.recordName)"
                    
                } else {
                    self.idLabel.text = "Got nothing"
                }
            }
        }
    }
    
    func fetchUserDetails() {
        let container = CKContainer.default()
        
        container.fetchUserRecordID { (record: CKRecordID?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    self.userDetailsLabel.text = "User details error: \(error)"
                }
                
            } else if let record = record {
                container.discoverUserIdentity(withUserRecordID: record, completionHandler: { (userId: CKUserIdentity?, error: Error?) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.userDetailsLabel.text = "User details 2 error: \(error)"
                            
                        } else if let userId = userId {
                            var text = "hasiCloudAccount: \(userId.hasiCloudAccount)"
                            
                            if let lookupInfo = userId.lookupInfo {
                                text += "\nlookupInfo.phoneNumber: \(lookupInfo.phoneNumber)"
                                text += "\nlookupInfo.emailAddress: \(lookupInfo.emailAddress)"
                                //text += "\n\nlookupInfo: \(lookupInfo)"
                            }
                            
                            if let nameComponents = userId.nameComponents {
                                text += "\n\nnameComponents: \(nameComponents)"
                            }
                            
                            self.userDetailsLabel.text = "User details: \(text)"
                            
                        } else {
                            self.userDetailsLabel.text = "Got nothing 2"
                        }
                    }
                })
                
            } else {
                self.userDetailsLabel.text = "Got nothing"
            }
        }
    }
    
    func requestPermissions() {
        let container = CKContainer.default()
        
        container.requestApplicationPermission(.userDiscoverability) { (status: CKApplicationPermissionStatus, error: Error?) in
            self.updatePermissionStatus()
        }
    }
    
    func updateAccountStatus() {
        let container = CKContainer.default()
        
        container.accountStatus { (status: CKAccountStatus, error: Error?) in
            DispatchQueue.main.async {
                var text = "unknown"
                if status == .couldNotDetermine {
                    text = "couldNotDetermine"
                } else if status == .available {
                    text = "available"
                } else if status == .restricted {
                    text = "restricted"
                } else if status == .noAccount {
                    text = "noAccount"
                }
                
                if let error = error {
                    text = "Error: \(error)"
                }
                
                self.accountStatusLabel.text = "Account status: \(text)"
            }
        }
    }
}

