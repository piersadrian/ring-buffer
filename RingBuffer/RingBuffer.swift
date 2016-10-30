//
//  RingBuffer.swift
//  RingBuffer
//
//  Created by Piers Mainwaring on 10/30/16.
//  Copyright © 2016 Playfair, LLC. All rights reserved.
//

import Foundation

class RingBuffer {
    internal var data: Data

    private let capacity: Int
    private var lock = DispatchQueue(label: "com.playfair.ringbuffer.lock")

    var start: Data.Index = 0 {
        didSet { start = start % capacity }
    }

    var count: Int = 0

    init(capacity: Int) {
        self.capacity = capacity
        self.data = Data(count: capacity)
    }

    public func readByte() -> UInt8? {
        return lock.sync { () -> UInt8? in
            if count > 0 {
                let byte = data[start]
                start += 1
                count -= 1
                return byte
            }

            return nil
        }
    }

    public func flush() -> Data {
        return lock.sync { () -> Data in
            var subdata = data.subdata(in: start..<capacity)
            let trailingData = data.subdata(in: 0..<capacity - start)
            subdata.append(trailingData)
            return subdata
        }
    }

    public func write(byte: UInt8) -> Bool {
        return lock.sync { () -> Bool in
            if count < capacity {
                let writePosition = (start + count) % capacity
                data[writePosition] = byte
                count += 1
                return true
            }

            return false
        }
    }

    public func write(data newData: Data) -> Int {
        var bytesWritten = 0

        for byte in newData {
            if write(byte: byte) {
                bytesWritten += 1
            }
            else {
                return bytesWritten
            }
        }
        
        return bytesWritten
    }
}
