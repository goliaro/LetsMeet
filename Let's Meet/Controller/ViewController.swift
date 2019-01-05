//
//  ViewController.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 11/30/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit
import Foundation

// Mutexes stuff from http://www.vadimbulavin.com/atomic-properties/
protocol Lock {
    func lock()
    func unlock()
}

extension NSLock: Lock {}

final class Mutex: Lock {
    private var mutex: pthread_mutex_t = {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        return mutex
    }()
    
    func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}

let mutex_signin = Mutex()


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

