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
        let button = UIButton(type: .Custom)
        view.addSubview(button)
        button.frame = CGRectMake(100, 100, 100, 100)
        button.backgroundColor = UIColor.blueColor()
        
        debugPrint(self.sy_routeParams)
    }
}
