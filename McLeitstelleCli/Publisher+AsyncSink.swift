//
//  Publisher+AsyncSink.swift
//  McLeitstelleCli
//
//  Created by Paul on 04.10.23.
//

import Combine

extension Publisher where Self.Failure == Never {
  func sink(receiveValue: @escaping ((Self.Output) async -> Void)) -> AnyCancellable {
    sink { value in
      Task {
        await receiveValue(value)
      }
    }
  }
}
