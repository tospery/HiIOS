//
//  HomeViewController.swift
//  HiIOSDemo
//
//  Created by 杨建祥 on 2024/5/8.
//

import UIKit
import HiIOS

class HomeViewController: UIViewController {
    
    lazy var testView: TestView = {
        let view = TestView(frame: .init(x: 0, y: 0, width: 200, height: 80))
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        self.view.addSubview(self.testView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.testView.left = self.testView.leftWhenCenter
        self.testView.top = self.testView.topWhenCenter
    }
    
}
