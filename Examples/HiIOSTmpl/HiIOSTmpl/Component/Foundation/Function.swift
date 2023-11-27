//
//  Function.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/11/27.
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
#if DEBUG
#else
    guard let message = message() as? String else { return }
    let aliyun = TLogFactory.createTLog(forModuleName: module)
    switch level {
    case .debug, .verbose:
        aliyun?.debug(message)
    case .info:
        aliyun?.info(message)
    case .warning:
        aliyun?.warn(message)
    case .error:
        aliyun?.error(message)
    }
#endif
}


func pullsPath(_ username: String, _ reponame: String) -> String {
    "/repos/\(username)/\(reponame)/pulls"
}

func issuesPath(_ username: String, _ reponame: String) -> String {
    "/repos/\(username)/\(reponame)/issues"
}
