//
//  ViewController.swift
//  SYRouter
//
//  Created by wangshiyu13 on 16/4/24.
//  Copyright © 2016年 wangshiyu13. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(self.click), for: .touchUpInside)
    }
    
    func click() {
        debugPrint("button--Click")
        let vc = SYRouter.shared.matchController("/B/:test/?test=1")
        self.present(vc, animated:true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
