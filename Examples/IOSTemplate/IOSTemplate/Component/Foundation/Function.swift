//
//  Function.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import SwiftyBeaver
import HiIOS

func log(
    _ message: @autoclosure () -> Any,
    module: Logger.Module = .common,
    level: Logger.Level = .debug,
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    context: Any? = nil
) {
    logger.print(message(), module: module, level: level, file: file, line: line, context: context)
}
