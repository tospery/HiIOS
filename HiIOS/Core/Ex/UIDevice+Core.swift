//
//  UIDevice+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import QMUIKit
import UICKeyChainStore
import FCUUID

public extension UIDevice {

    var modelName: String {
        QMUIHelper.deviceName
    }
    
    var keychain: UICKeyChainStore {
        let service = "device.info"
        let accessGroup = UIApplication.shared.team + ".shared"
        let keychain = UICKeyChainStore(service: service, accessGroup: accessGroup)
        return keychain
    }

    var uuid: String {
        let keychain = self.keychain
        let key = "uuid"
        var uuid = keychain[key]
        if uuid?.isEmpty ?? true {
            uuid = FCUUID.uuidForDevice()
            keychain[key] = uuid
        }
        return uuid!
    }

}
