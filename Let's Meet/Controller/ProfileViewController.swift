//
//  ProfileViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Foundation

struct UserInfo: Codable {
    var name: String
    var username: String
    var email: String
}


class ProfileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    
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
    
    func dowloadInfo()
    {
        restoreCookies()
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/get_user_info.php")
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            
            print(response)
            
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do {
                //here dataResponse received from a network request
                let decoder = JSONDecoder()
                let user = try decoder.decode([UserInfo].self, from:
                    dataResponse) //Decode JSON Response Data
                print(user[0])
                
                DispatchQueue.main.async {
                    self.NameTextField.text = user[0].name as String?
                    self.UsernameTextField.text = user[0].username as String?
                    self.EmailTextField.text = user[0].email as String?
                }
                
            } catch let parsingError {
                print("Error", parsingError)
                return
            }
            
        }
        task.resume()
    }
    
    func downloadImage()
    {
        // download the profile picture
        let imageLocation = "https://www.gabrieleoliaro.it/db/uploads/profile_pictures/" + UUsername! + ".jpg"
        print("imagelocation:" + imageLocation)
        guard let imageUrl = URL(string: imageLocation) else {
            print("Cannot create URL")
            return
        }
        let image_task = URLSession.shared.downloadTask(with: imageUrl) {(location, response, error) in
            guard let location = location else {
                print("location is nil")
                return
            }
            print(location)
            let imageData = try! Data(contentsOf: location)
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.profilePictureImageView.image = image
            }
        }
        image_task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dowloadInfo()
        downloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        
        // local mutex used to make sure that we don't perform the segue before we have finished logging out
        let local_mutex = Mutex()
        local_mutex.lock()
        var logged_out = false
        
        // call logout php
        
        // download the profile picture
        let logoutpage = "https://www.gabrieleoliaro.it/db/logout.php"
        guard let logouturl = URL(string: logoutpage) else {
            print("Cannot connect to logout page")
            local_mutex.unlock()
            return
        }
        let task = URLSession.shared.dataTask(with: logouturl) {(data, response, error) in
            guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                local_mutex.unlock()
                return
            }
            
            if (dataResponse != "Logged out.")
            {
                // main thread
                print(dataResponse)
                DispatchQueue.main.async {
                    self.showAlertView(error_message: dataResponse)
                }
                return
            }
            
            else {
                logged_out = true
            }
            
            local_mutex.unlock()
            
        }
        task.resume()
        local_mutex.lock()
        if (logged_out) {
            eraseCookies()
            self.performSegue(withIdentifier: "logoutSegue", sender: sender)
        }
        local_mutex.unlock()
        
        
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
