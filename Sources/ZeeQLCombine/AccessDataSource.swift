//
//  AccessDataSourceCombine.swift
//  ZeeQL
//
//  Created by Helge Heß on 22.08.19.
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

#if canImport(Combine)

import class  Dispatch.DispatchQueue
import ZeeQL
import struct Combine.AnyPublisher
import class  Combine.Future
import struct Combine.Fail

@available(iOS 13, tvOS 13, OSX 10.15, watchOS 6, *)
public extension AccessDataSource {
  
  func fetchObjects(_ fs: FetchSpecification,
                    on queue: DispatchQueue = .global())
       -> AnyPublisher<Object, Error>
  {
    AccessDataSourcePublisher(
      dataSource: self, fetchSpecification: fs, queue: queue
    )
    .eraseToAnyPublisher()
  }
  
  func fetchCount(_ fs: FetchSpecification,
                  on queue: DispatchQueue = .global())
       -> AnyPublisher<Int, Error>
  {
    Future { promise in
      queue.async {
        do {
          // TBD: Why isn't this public? I guess because we are supposed to
          //      set the FS on the datasource.
          let count = try self._primaryFetchCount(fs)
          promise(.success(count))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func fetchGlobalIDs(_ fs: FetchSpecification,
                      on queue: DispatchQueue = .global())
       -> AnyPublisher<[ GlobalID ], Error>
  {
    Future { promise in
      queue.async {
        do {
          var gids = [ GlobalID ]()
          try self._primaryFetchGlobalIDs(fs) { gids.append($0) }
          promise(.success(gids))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func fetchObjects<S: Sequence>(with globalIDs: S,
                                 on queue: DispatchQueue = .global())
       -> AnyPublisher<Object, Error>
       where S.Element: GlobalID
  {
    guard let entity = entity else {
      return Fail(error: AccessDataSourceError.MissingEntity)
               .eraseToAnyPublisher()
    }
    
    let gidQualifiers = globalIDs.map { entity.qualifierForGlobalID($0) }
    let fs = ModelFetchSpecification(entity: entity,
                                     qualifier: gidQualifiers.or())
    return AccessDataSourcePublisher(
      dataSource: self, fetchSpecification: fs, queue: queue
    )
    .eraseToAnyPublisher()
  }
}

#endif // canImport(Combine)

