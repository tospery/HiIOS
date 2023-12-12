//
//  User+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import Foundation
import BonMot

extension User {

    var fullname: String {
        let unknown = R.string(preferredLanguages: myLangs).localizable.unknown()
        return "\(self.nickname ?? unknown) (\(self.username ?? unknown))"
    }
    
    var repoAttributedText: NSAttributedString {
        .composed(of: [
            R.image.ic_repo_small()!
                .styled(with: .baselineOffset(-4)),
            Special.space,
           (self.repo?.name ?? R.string(preferredLanguages: myLangs).localizable.noneRepo())
                .attributedString()
        ]).styled(with: .color(.primary), .font(.bold(14)))
    }
    
}
