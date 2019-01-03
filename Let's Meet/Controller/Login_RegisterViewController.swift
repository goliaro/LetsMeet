//
//  Login_RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit

func getPostString(params:[String:Any]) -> String
{
    var data = [String]()
    for(key, value) in params
    {
        data.append(key + "=\(value)")
    }
    return data.map { String($0) }.joined(separator: "&")
}

struct UserInfo: Codable {
    var name: String
    var username: String
    var email: String
    var picture_url: String
}

// cookies functions from https://stackoverflow.com/questions/43980588/how-to-save-cookies-in-shared-preferences-in-ios
func storeCookies() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    let serverBaseUrl = "https://www.gabrieleoliaro.it"
    var cookieDict = [String : AnyObject]()
    
    for cookie in cookiesStorage.cookies(for: NSURL(string: serverBaseUrl)! as URL)! {
        cookieDict[cookie.name] = cookie.properties as AnyObject?
    }
    
    userDefaults.set(cookieDict, forKey: "cookiesKey")
}

func eraseCookies() {
    let cookiesStorage = HTTPCookieStorage.shared
    
    let serverBaseUrl = "https://www.gabrieleoliaro.it"
    var cookieDict = [String : AnyObject]()
    
    for cookie in cookiesStorage.cookies(for: NSURL(string: serverBaseUrl)! as URL)! {
        cookiesStorage.deleteCookie(cookie)
        
    }
    
}

func restoreCookies() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    if let cookieDictionary = userDefaults.dictionary(forKey: "cookiesKey") {
        
        for (_, cookieProperties) in cookieDictionary {
            if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                cookiesStorage.setCookie(cookie)
            }
        }
    }
}

class Login_RegisterViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
    }
    
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
    
    func login(post_params: [String:Any], url:String)
    {
        //restoreCookies()
        eraseCookies()
        let webservice_URL = URL(string: url)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "text/html",
                                        "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "POST"
        
        let parameterArray = getPostString(params: post_params)
        request.httpBody = parameterArray.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) { data, response, error in
            
            print(response)
            
            guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            if (dataResponse != "success_login." && dataResponse != "success_cookie")
            {
                // main thread
                DispatchQueue.main.async {
                    self.showAlertView(error_message: dataResponse)
                }
                return
            }
            print(dataResponse)
            storeCookies()
            
            
        }
        task.resume()
    }
    
    // MARK: Actions
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        
        // Make sure that the username and password are both filled in
        if (UsernameTextField.text!.count == 0 || PasswordTextField.text!.count == 0)
        {
            // main thread
            DispatchQueue.main.async {
                self.showAlertView(error_message: "Username and password must be filled in")
            }
            return
        }
        
        let login_params:[String:String] = ["username": UsernameTextField.text!, "password": PasswordTextField.text!]
        login(post_params: login_params, url: "https://www.gabrieleoliaro.it/db/login.php")
        
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
