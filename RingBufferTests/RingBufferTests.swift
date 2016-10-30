//
//  RingBufferTests.swift
//  RingBufferTests
//
//  Created by Piers Mainwaring on 10/28/16.
//  Copyright © 2016 Playfair, LLC. All rights reserved.
//

import XCTest

class RingBufferTests: XCTestCase {

    func testWriteWhenNotFull() {
        let buf = RingBuffer(capacity: 4)
        let _ = buf.write(data: Data(bytes: [65]))
        let _ = buf.write(data: Data(bytes: [66]))
        XCTAssert(buf.data.elementsEqual([65,66,0,0]), "bytes don't match")
    }

    func testWriteWhenFull() {
        let buf = RingBuffer(capacity: 2)
        let _ = buf.write(data: Data(bytes: [65]))
        let _ = buf.write(data: Data(bytes: [66]))
        let wroteCount = buf.write(data: Data(bytes: [67]))
        XCTAssertEqual(wroteCount, 0, "wrote to buffer when it shouldn't")
    }

    func testRead() {
        let buf = RingBuffer(capacity: 4)
        let _ = buf.write(data: Data(bytes: [65]))
        let _ = buf.write(data: Data(bytes: [66]))
        let byte = buf.readByte()
        XCTAssertEqual(byte, 65, "wrong byte order")
    }

    func testWrappingIO() {
        let buf = RingBuffer(capacity: 2)
        XCTAssertEqual(buf.write(data: Data(bytes: [65])), 1, "couldn't write byte1")
        XCTAssertEqual(buf.write(data: Data(bytes: [66])), 1, "couldn't write byte2")

        XCTAssertEqual(buf.readByte(), 65, "byte1 doesn't match")
        XCTAssertEqual(buf.readByte(), 66, "byte2 doesn't match")

        XCTAssertEqual(buf.write(data: Data(bytes: [67])), 1, "couldn't write byte3")
        XCTAssertEqual(buf.write(data: Data(bytes: [68])), 1, "couldn't write byte4")

        XCTAssertEqual(buf.readByte(), 67, "byte3 doesn't match")
        XCTAssertEqual(buf.readByte(), 68, "byte4 doesn't match")
    }

    func testFlush() {
        let buf = RingBuffer(capacity: 2)
        let _ = buf.write(data: Data(bytes: [65]))
        let _ = buf.write(data: Data(bytes: [66]))
        let _ = buf.readByte()
        let _ = buf.write(data: Data(bytes: [67]))

        XCTAssert(buf.flush().elementsEqual([66,67]), "flushed buffer doesn't match")
    }
    
}
