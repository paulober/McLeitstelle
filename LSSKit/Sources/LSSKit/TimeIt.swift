//
//  TimeIt.swift
//  
//
//  Created by Paul on 14.09.23.
//

import Foundation

@preconcurrency public func TimeIt(_ prefix: String, execute work: @escaping @Sendable @convention(block) () -> Void) {
    let startTime = DispatchTime.now()
    work()
    let endTime = DispatchTime.now()
    print("[TimeIt - \(prefix)] \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0)ms")
}
