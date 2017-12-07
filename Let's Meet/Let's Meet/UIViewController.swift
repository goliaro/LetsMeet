//
//  UIViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import Foundation
import MessageUI

extension UIViewController : MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController(recipients : [String]?, subject :
        String, body : String, isHtml : Bool = false,
                images : [UIImage]?) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // IMPORTANT
        
        mailComposerVC.setToRecipients(recipients)
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(body, isHTML: isHtml)
        
        for img in images ?? [] {
            if let jpegData = UIImageJPEGRepresentation(img, 1.0) {
                mailComposerVC.addAttachmentData(jpegData,
                                                 mimeType: "image/jpg",
                                                 fileName: "Image")
            }
        }
        
        return mailComposerVC
    }
    
    func presentMailComposeViewController(mailComposeViewController :
        MFMailComposeViewController) {
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController,
                         animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertController.init(title: "Error",
                                                            message: "Unable to send email. Please check your email " +
                "settings and try again.", preferredStyle: .alert)
            self.present(sendMailErrorAlert, animated: true,
                         completion: nil)
        }
    }
    
    public func mailComposeController(controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: NSError?) {
        switch (result) {
        case .cancelled:
            self.dismiss(animated: true, completion: nil)
        case .sent:
            self.dismiss(animated: true, completion: nil)
        case .failed:
            self.dismiss(animated: true, completion: {
                let sendMailErrorAlert = UIAlertController.init(title: "Failed",
                                                                message: "Unable to send email. Please check your email " +
                    "settings and try again.", preferredStyle: .alert)
                sendMailErrorAlert.addAction(UIAlertAction.init(title: "OK",
                                                                style: .default, handler: nil))
                self.present(sendMailErrorAlert,
                             animated: true, completion: nil)
            })
        default:
            break;
        }
    }
    
    func versionText () -> String {
        let bundleVersionKey = "CFBundleShortVersionString"
        let buildVersionKey = "CFBundleVersion"
        
        if let version = Bundle.main.object(forInfoDictionaryKey: bundleVersionKey) {
            if let build = Bundle.main.object(forInfoDictionaryKey: buildVersionKey) {
                let version = "Version \(version) - Build \(build)"
                return version
            }
        }
        
        return ""
    }
}
