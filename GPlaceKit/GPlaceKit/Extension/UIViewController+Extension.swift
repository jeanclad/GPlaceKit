//
//  UIViewController+Extension.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertMessage(_ title: String,
                      message: String,
                      completionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let handler = completionHandler ?? { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        let okAction = UIAlertAction(title: "확인",
                                     style: UIAlertActionStyle.default,
                                     handler: handler)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
