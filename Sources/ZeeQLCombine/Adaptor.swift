//
//  File.swift
//  
//
//  Created by Helge Heß on 12.09.19.
//

#if canImport(Combine)
import class  Dispatch.DispatchQueue
import ZeeQL
import struct Combine.AnyPublisher
import class  Combine.Future

@available(iOS 13, tvOS 13, OSX 10.15, watchOS 6, *)
public extension Adaptor {

  func fetchModel(on queue: DispatchQueue = .global())
       -> AnyPublisher<( model: Model, tag: ModelTag ), Error>
  {
    Future { promise in
      queue.async {
        do { // TODO: should run in a single TX
          let model = try self.fetchModel()
          let tag   = try self.fetchModelTag()
          promise(.success( ( model: model, tag: tag ) ))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}

#endif // Combine
