//
//  ViewController + Interactions.swift
//  VodafoneBusinessCard
//
//  Created by Kiro on 12/9/18.
//  Copyright © 2018 Kiro. All rights reserved.
//

import Foundation
import MessageUI
import WebKit
import Contacts
import UIKit

enum nodeTypes:String {
    case phone = "phone"
    case facebook = "facebook"
    case message = "message"
    case email = "email"
    case saveContact = "saveContact"

}

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self.sceneView), let hitTestResult = self.sceneView.hitTest(touchLocation, options: nil).first?.node.name, let nodeType = nodeTypes.init(rawValue: hitTestResult) else { return }
       
        switch nodeType {
        case .phone:
            callPhoneNumber(self.businessCardNode.businessCard.phoneNumber)
        case .facebook:
            self.openFacebookPage(self.businessCardNode.businessCard.facebook)
        case .message:
            self.sendSMSTo(self.businessCardNode.businessCard.phoneNumber)
        case .email:
            self.sendEmailTo(self.businessCardNode.businessCard.email)
        case .saveContact:
            self.saveContactToAddressBook()
        }
    }
    
    func callPhoneNumber(_ number: String){
        
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            
            menuShown = true
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }else{
            print("Error Trying To Connect To Mobile Provider")
        }
    }
    
    
    func openFacebookPage(_ facebook: String){
        
        if let url = URL(string: "https://www.facebook.com/\(facebook)"), UIApplication.shared.canOpenURL(url) {
            
            menuShown = true
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }else{
            print("Error Trying To Connect To Mobile Provider")
        }
    }
    
    
    /// Sends An SMS To The Number On The Business Card
    ///
    /// - Parameter number: String
    func sendSMSTo(_ number: String){
        
        if MFMessageComposeViewController.canSendText(){
            menuShown = true
            
            let smsController = MFMessageComposeViewController()
            smsController.body = "Dear Kirollos\nWelcome to Vodafone UK"
            smsController.recipients = [number]
            smsController.messageComposeDelegate = self
            present(smsController, animated: true, completion: nil)
        }else{
            print("Error Loading SMS Composer")
        }
        
    }
    
    /// Sends An Email To The Business Card Holder
    ///
    /// - Parameter recipient: String
    func sendEmailTo(_ recipient: String){
        
        if MFMailComposeViewController.canSendMail(){
            
            menuShown = true
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Vodafone UK")
            mailComposer.setToRecipients([recipient])
            present(mailComposer, animated: true, completion: nil)
        }else{
            print("Error Loading Email Composer")
        }
        
    }
    
    /// Loads One Of The Website From Business Card
    func displayWebSite() { self.performSegue(withIdentifier: "webViewer", sender: nil) }
    
    //----------------------------------
    //MARK: - Save Associate To Contacts
    //----------------------------------
    
    /// Saves The Business Profile To The Users Device
    func saveContactToAddressBook(){
        
        //1. Create A Contact
        let businessContact = CNMutableContact()
        
        //2. Create The First & Last Names Of The Contact & The Associates Job Title
        let fullName = businessCardNode.businessCard.firstname + " " + businessCardNode.businessCard.lastname
        businessContact.givenName = businessCardNode.businessCard.firstname
        businessContact.familyName = businessCardNode.businessCard.lastname
        businessContact.jobTitle = businessCardNode.businessCard.jobTitle
        businessContact.organizationName = businessCardNode.businessCard.company
        
        //3. Create The Profile Image
        if let profileImage = UIImage(named: businessCardNode.businessCard.firstname+businessCardNode.businessCard.lastname),
            let profileData  = profileImage.pngData(){
            businessContact.imageData = profileData
        }
        
        //4. Set The Associates Work Email
        let workEmail = CNLabeledValue(label:CNLabelWork, value: businessCardNode.businessCard.email as NSString)
        businessContact.emailAddresses = [workEmail]
        
        //5. Set The Associates Work Phone Number
        businessContact.phoneNumbers = [CNLabeledValue ( label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: businessCardNode.businessCard.phoneNumber))]
        
        //6. Set The Associates Work Address
        let address = CNMutablePostalAddress()
        address.street = "Vodafone MCCP"
        businessContact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: address)]
        
        //8. Save It To The Device
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(businessContact, toContainerWithIdentifier:nil)
        
        do{
            try store.execute(saveRequest)
            showSaveMessage("\(fullName) Saved To Contacts")
            
        }catch{
            showSaveMessage("\(fullName) Not Saved To Contacts")
        }
        
    }
    
    func showSaveMessage(_ message: String){
        
        let saveMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        saveMessage.addAction(dismissButton)
        present(saveMessage, animated: true, completion: nil)
    }
}


extension ViewController: MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true) { self.menuShown = false }
        
    }
    
}

