//
//  LeaveOrDeleteGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 06/01/2019.
//  Copyright © 2019 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit

class LeaveOrDeleteGroupViewController: UIViewController {
    
    var group_name: String?
    var owner: String?
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    
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

        // only the owner can delete the group
        print("\n\n\n\n owner: "); print(owner)
        print("\n UUsername: "); print(UUsername)
        print("\n group_name: "); print(group_name)
        if (owner == UUsername)
        {
            deleteButtonOutlet.isEnabled = true
        }
        
        // Do any additional setup after loading the view.
    }
    
    func removeMember(post_params: [String:Any], url:String) -> String
    {
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        // remove cookies from previous sessions
        restoreCookies()
        
        let webservice_URL = URL(string: url)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "text/html",
                                        "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        var toreturn = "Failed."
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "POST"
        
        let parameterArray = getPostString(params: post_params)
        request.httpBody = parameterArray.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) { data, response, error in
            
            print(response)
            
            guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                
                // done with the datatask (failed), so unlock the mutex
                local_mutex.unlock()
                //print("toreturn: "); print(toreturn); print("\n")
                return
            }
            
            print("dataResponse: " + dataResponse + "\n")
            
            if (dataResponse != "Successfully removed the user.")
            {
                // main thread
                DispatchQueue.main.async {
                    self.showAlertView(error_message: dataResponse)
                }
                
            }
            else {
                // Success!
                toreturn = "Success!"
            }
            
            print("toreturn: "); print(toreturn); print("\n")
            
            // we should be all done with the dataTask once we get here. No matter if we succeeded or failed
            local_mutex.unlock()
            
        }
        task.resume()
        
        // Aquire the lock right before returning, to make sure that we are actually done with the dataTask
        local_mutex.lock()
        
        return toreturn
    }
    
    @IBAction func leaveGroupButton(_ sender: UIButton) {
        let remove_params:[String:String] = ["member_username": UUsername!, "group_name": group_name!]
        showAlertView(error_message: removeMember(post_params: remove_params, url: "https://www.gabrieleoliaro.it/db/remove_member_from_group.php"))
        
        performSegue(withIdentifier: "unwindToGroupTableView", sender: sender)
        
    }
    
    @IBAction func deleteGroupButton(_ sender: UIButton) {
        let remove_params:[String:String] = ["member_username": UUsername!, "group_name": group_name!]
        showAlertView(error_message: removeMember(post_params: remove_params, url: "https://www.gabrieleoliaro.it/db/remove_member_from_group.php"))
        
        performSegue(withIdentifier: "unwindToGroupTableView", sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
