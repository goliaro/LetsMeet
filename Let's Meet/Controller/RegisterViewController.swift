//
//  RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Foundation

func imageUploadRequest(imageView: UIImageView, uploadUrl: URL, param: [String:String]?, username: String)
{
    var request = URLRequest(url: uploadUrl);
    request.httpMethod = "POST"
    let boundary = generateBoundaryString()
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = [
        "Accept": "text/html",
        "Content-Type": "multipart/form-data; boundary=\(boundary)",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
        
    ]
    let session = URLSession(configuration: config)
    
    let imageasdata = UIImageJPEGRepresentation(imageView.image!, 1)
    if (imageasdata == nil) {
        return
    }
    
    request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageasdata!, boundary: boundary, username: username)
    
    //myActivityIndicator.startAnimating();
    print("printing request now")
    print(request)
    
    let task = session.dataTask(with: request) { data, response, error in
        guard error == nil && data != nil else {
            print(error)
            return
        }
        print(response)
        guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
            print(error?.localizedDescription ?? "Response Error")
            return
        }
        print(dataResponse)
    }
    task.resume()
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String, username: String) -> Data {
    var body = Data()
    
    if parameters != nil {
        for (key, value) in parameters! {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
    }
    
    var filename = username + ".jpg"
    
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
        imageUploadRequest(imageView: profilePhotoImageView, uploadUrl: webservice_URL!, param: register_params, username: usernameTextField.text!)
        
        
    }
    
    
    @IBAction func loadImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        
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
        profilePhotoImageView.image = pickedImage
        
        // save image into globals so that we can access it
        pickedImage = pi
        pickedImageURL = pu
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // #cs50 Hide the keyboard
        textField.resignFirstResponder()
        
        if (textField.tag > 2)
        {
            // Scroll back up to show all the elements in the page
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // #cs50 When the user starts typing, scroll down the page using a scroll view, so that no textfield is covered by the keyboard.
        // If the selected text field is the password or the confirm password one (We tagged them from 1 to 4 in order), scroll down so that the text field is not hidden by the keyboard
        if (textField.tag > 2) {
            scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

