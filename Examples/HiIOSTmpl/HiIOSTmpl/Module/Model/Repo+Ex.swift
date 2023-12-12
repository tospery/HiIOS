//
//  Repo+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import BonMot
// import DateToolsSwift_JX
import HiIOS

extension Repo {
    
//    var updateAgo: String? {
//        guard let string = self.updatedAt else { return nil }
//        guard let date = Date.init(iso8601: string) else { return nil }
//        return R.string.localizable.latestUpdate(
//            date.timeAgoSinceNow, preferredLanguages: myLangs
//        )
//    }
    
//    var sizeAndLicense: String? {
//        let noneLicense = R.string.localizable.noneLicense(preferredLanguages: myLangs)
//        return "\(self.size.kilobytesText)(\(self.license?.spdxId ?? noneLicense))"
//    }
    
    var fullnameAttributedText: NSAttributedString {
        .composed(of: [
            (self.owner.username ?? R.string(preferredLanguages: myLangs).localizable.unknown())
                .styled(with: .color(.primary)),
            " / ",
            (self.name ?? R.string(preferredLanguages: myLangs).localizable.unknown())
                .styled(with: .color(.foreground))
        ]).styled(with: .font(.bold(16)))
    }
    
    var introAttributedText: NSAttributedString {
        .composed(of: [
            "●".styled(with: .color(self.languageColor?.color ?? .random)),
            Special.space,
            (self.language ?? R.string(preferredLanguages: myLangs).localizable.unknown())
                .styled(with: .color(.foreground)),
            Special.space,
            Special.space,
            R.image.ic_star()!.template.styled(with: .baselineOffset(-1), .color(.foreground)),
            Special.space,
            self.stars.formatted.styled(with: .color(.foreground)),
            Special.space,
            Special.space,
            R.image.ic_fork()!.template.styled(with: .baselineOffset(-1), .color(.foreground)),
            Special.space,
            self.forks.formatted.styled(with: .color(.foreground))
        ]).styled(with: .font(.normal(13)))
    }
    
    var languageAttributedText: NSAttributedString {
        .composed(of: [
            "●".styled(with: .color(self.languageColor?.color ?? .random)),
            Special.space,
            (self.language ?? R.string(preferredLanguages: myLangs).localizable.unknown())
                .styled(with: .color(.foreground))
        ]).styled(with: .font(.normal(11)))
    }
    
    var starsAttributedText: NSAttributedString {
        .composed(of: [
            R.image.ic_star()!.template
                .styled(with: .baselineOffset(-1)),
            Special.space,
            self.stars.formatted
                .attributedString()
        ]).styled(with: .font(.normal(11)), .color(.foreground))
    }
    
    var forksAttributedText: NSAttributedString {
        .composed(of: [
            R.image.ic_fork()!.template
                .styled(with: .baselineOffset(-2)),
            Special.space,
            self.forks.formatted
                .attributedString()
        ]).styled(with: .font(.normal(11)), .color(.foreground))
    }
    
//    func branch(in lists: [Branch]) -> Branch? {
//        guard let name = self.defaultBranch?.lowercased(), name.isNotEmpty else { return nil }
//        var branch: Branch?
//        for item in lists where item.id.lowercased() == name {
//            branch = item
//            break
//        }
//        return branch
//    }
    
}
