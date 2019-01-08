//
//  RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit
import Foundation


extension Data {
    mutating func append(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

//credits: https://stackoverflow.com/questions/26335656/how-to-upload-images-to-a-server-in-ios-with-swift?noredirect=1&lq=1
func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String, name: String) -> Data {
    var body = Data()
    
    if parameters != nil {
        for (key, value) in parameters! {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
    }
    
    let filename = name + ".jpg"
    
    let mimetype = "image/jpg"
    
    body.append(Data("--\(boundary)\r\n".utf8))
    body.append(Data(("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n").utf8))
    body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
    body.append(imageDataKey)
    body.append(Data("\r\n".utf8))
    
    body.append(Data("--\(boundary)--\r\n".utf8))
    
    return body
}

func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}


class RegisterViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
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
    
    func register(param: [String:String]?, username: String, uploadUrl: URL, imageView: UIImageView) -> Bool
    {
        eraseCookies()
     
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
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageasdata!, boundary: boundary, name: username)
        
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
            if (dataResponse != "Your registration was successful")
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Cancel and unwind to login/register homepage
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func register_button(_ sender: UIBarButtonItem) {
        
        // Ensure the name and email address fields are not empty
        if (nameTextField.text == "" || emailTextField.text == "" || usernameTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == "") {
            DispatchQueue.main.async {
                self.showAlertView(error_message: "name, username, email and password must be filled in.")
            }
            return
        }
        else if (passwordTextField.text != confirmPasswordTextField.text) {
            DispatchQueue.main.async {
                self.showAlertView(error_message: "passwords do not match")
            }
            return
        }
        else if (passwordTextField.text!.count < 6 || passwordTextField.text!.count > 20) {
            DispatchQueue.main.async {
                self.showAlertView(error_message: "password should be between 6 and 20 characters")
            }
            return
        }
        
        
        // register
        let register_params:[String:String] = ["username": usernameTextField.text!, "name": nameTextField.text!, "password": passwordTextField.text!, "password2": confirmPasswordTextField.text!, "email": emailTextField.text!, "submit": "upload"]
        //register(post_params: register_params, url: "https://www.gabrieleoliaro.it/db/register_new.php")
        
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/register_new.php")
        
        if register(param: register_params, username: usernameTextField.text!, uploadUrl: webservice_URL!, imageView: profilePhotoImageView)
        {
            UUsername = usernameTextField.text!
            performSegue(withIdentifier: "showGroupsTable", sender: sender)
        }
        
        
    }
    
    
    @IBAction func loadImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        // remove image from imageview preview
        let noimage: UIImage = UIImage(named: "defaultPhoto")!
        profilePhotoImageView.image = noimage
        
    }
    
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
        profilePhotoImageView.contentMode = .scaleAspectFit
        profilePhotoImageView.image = pi
        
        // save image into globals so that we can access it
        pickedImage = pi
        pickedImageURL = pu
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    
}

