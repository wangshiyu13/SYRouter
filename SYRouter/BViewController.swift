//
//  BViewController.swift
//  SYRouter
//
//  Created by wangshiyu13 on 16/4/24.
//  Copyright © 2016年 wangshiyu13. All rights reserved.
//

import UIKit

class BViewController: UIViewController {
    var test: String = "test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.blue
        
        debugPrint(self.sy_routeParams as Any)
    }
}
