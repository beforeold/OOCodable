//
//  File.swift
//  
//
//  Created by beforeold on 2022/8/25.
//

import Foundation

@propertyWrapper
public struct SafeInt {
    public typealias Wrapped = Int
    public var wrappedValue: Wrapped = 0
    
    public init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
    
    public init() {
        self.wrappedValue = 0
    }
}

extension SafeInt: Decodable {
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            return
        }
        
        if let int = try? container.decode(Int.self) {
            self.wrappedValue = int
            return
        }
        
        if let double = try? container.decode(Double.self) {
            self.wrappedValue = Int(double)
            return
        }
        
        if let bool = try? container.decode(Bool.self) {
            self.wrappedValue = bool ? 1 : 0
            return
        }
        
        if let string = try? container.decode(String.self) {
            if let int = Int(string) {
                self.wrappedValue = int
            } else if StringUitl.isTrue(string: string) {
                self.wrappedValue = 1
            }
            return
        }
    }
}

extension KeyedDecodingContainer {
    func decode(
        _ type: SafeInt.Type,
        forKey key: Key
    ) throws -> SafeInt {
        guard let ret = try decodeIfPresent(type, forKey: key) else {
            return SafeInt()
        }
        return ret
    }
}

extension SafeInt: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(self.wrappedValue)
    }
}
