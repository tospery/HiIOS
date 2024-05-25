//
//  UITableView+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit

public extension UITableView {
    
    func emptyCell(for indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableView.emptyCell"
        self.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.isHidden = true
        return cell
    }
    
}
