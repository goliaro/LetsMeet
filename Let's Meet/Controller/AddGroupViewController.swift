//
//  CreateNewGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit
import os.log

class CreateNewGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: Properties
    @IBOutlet weak var newGroupNameField: UITextField!
    @IBOutlet weak var newGroupDescriptionField: UITextField!
    @IBOutlet weak var newGroupProfilePhotoImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var group_key: String?
    var pickedImage: UIImage?
    var pickedImageURL: URL?
    
    func showAlertView(error_message: String)
    {
        // Show an alert message
        let alertController = UIAlertController(title: "Alert", message: error_message, preferredStyle: .alert)
        let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            //print("You've pressed OK");
        }
        alertController.addAction(OK_button)
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
    }
    

    
    func create_group(param: [String:String]?, groupname: String, uploadUrl: URL, imageView: UIImageView) -> Bool
    {
        restoreCookies()
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        var toreturn = false
        
        var request = URLRequest(url: uploadUrl);
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "text/html",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" // otherwise the server doesn't let us upload images
            
        ]
        let session = URLSession(configuration: config)
        
        let imageasdata = UIImageJPEGRepresentation(imageView.image!, 1)
        if (imageasdata == nil) {
            
            local_mutex.unlock()
            return toreturn
        }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageasdata!, boundary: boundary, name: groupname)
        
        print("printing request now")
        print(request)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil && data != nil else {
                print(error)
                
                // done with the datatask (failed), so unlock the mutex
                local_mutex.unlock()
                
                return
            }
            
            print(response)
            
            guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                
                // done with the datatask (failed), so unlock the mutex
                local_mutex.unlock()
                
                return
            }
            
            print(dataResponse)
            if (dataResponse != "New group was created with success.")
            {
                // main thread
                DispatchQueue.main.async {
                    self.showAlertView(error_message: dataResponse)
                }
            }
            else {
                // Success!
                storeCookies()
                toreturn = true
            }
            
            local_mutex.unlock()
        }
        
        task.resume()
        
        // Aquire the lock right before returning, to make sure that we are actually done with the dataTask
        local_mutex.lock()
        
        return toreturn
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "addMember":
            os_log("Adding new members", log: OSLog.default, type: .debug)
            
            guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination view controller \(segue.destination)")
            }
            
            guard let AddMemberToGroupViewController = navVC.viewControllers.first as? AddMemberToGroupViewController else {
                fatalError("Unexpected destination: \(navVC.viewControllers.first)")
                
            }
            
            AddMemberToGroupViewController.group_key = self.group_key
            

            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
            
    }*/
    
    
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        
        // Make sure that the group name was inserted
        if (newGroupNameField.text! == "")
        {
            showAlertView(error_message: "Please provide a name for the new group")
            return
        }
        
        // make post request to create group
        let create_group_params:[String:String] = ["name": newGroupNameField.text!, "description": newGroupDescriptionField.text!, "submit": "upload"]
        
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/create_group.php")
        
        if create_group(param: create_group_params, groupname: newGroupNameField.text!, uploadUrl: webservice_URL!, imageView: newGroupProfilePhotoImageView)
        {
            //unwind to groupsview
            self.performSegue(withIdentifier: "createGroupWithoutAddingMembers", sender: sender)
        }
        
        
        
        
    }
    
    @IBAction func pickProfilePhotoFromLibrary(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func removePicture(_ sender: UIButton) {
        // remove image from imageview preview
        let noimage: UIImage = UIImage(named: "defaultPhoto")!
        newGroupProfilePhotoImageView.image = noimage
    }
    
    
    // MARK: ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        guard let pi = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            print("could not get image you selected")
            return
        }
        guard let pu = info[UIImagePickerControllerReferenceURL] as? URL else
        {
            print("could not get image url")
            return
        }
        print(pu)
        
        // if survived
        // set image into imageview for a quick preview
        newGroupProfilePhotoImageView.contentMode = .scaleAspectFit
        newGroupProfilePhotoImageView.image = pi
        
        // save image into globals so that we can access it
        pickedImage = pi
        pickedImageURL = pu
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}
