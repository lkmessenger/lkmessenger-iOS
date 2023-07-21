//
// Copyright 2022 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import XCTest
import CocoaLumberjack
import Signal

final class OWSScrubbingLogFormatterTest: XCTestCase {
    private var formatter: OWSScrubbingLogFormatter { OWSScrubbingLogFormatter() }

    private func message(with string: String) -> DDLogMessage {
        DDLogMessage(
            message: string,
            level: .info,
            flag: [],
            context: 0,
            file: "mock file name",
            function: "mock function name",
            line: 0,
            tag: nil,
            options: [],
            timestamp: Date.init(timeIntervalSinceNow: 0)
        )
    }

    private lazy var datePrefixLength: Int = {
        // Other formatters add a dynamic date prefix to log lines. We truncate that when comparing our expected output.
        formatter.format(message: message(with: ""))!.count
    }()

    private func format(_ input: String) -> String {
        formatter.format(message: message(with: input)) ?? ""
    }

    private func stripDate(fromRawMessage rawMessage: String) -> String {
        rawMessage.substring(from: datePrefixLength)
    }

    func testDataScrubbed_preformatted() {
        let testCases: [String: String] = [
            "<01>": "[ REDACTED_DATA:01... ]",
            "<0123>": "[ REDACTED_DATA:01... ]",
            "<012345>": "[ REDACTED_DATA:01... ]",
            "<01234567>": "[ REDACTED_DATA:01... ]",
            "<01234567 89>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a2>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23d>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 2323>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 232345>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23234567>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23234567 89>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23234567 89ab>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23234567 89ab12>": "[ REDACTED_DATA:01... ]",
            "<01234567 89a23def 23234567 89ab1234>": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0xaa}": "[ REDACTED_DATA:aa... ]",
            "{length = 32, bytes = 0xaaaaaaaa}": "[ REDACTED_DATA:aa... ]",
            "{length = 32, bytes = 0xff}": "[ REDACTED_DATA:ff... ]",
            "{length = 32, bytes = 0xffff}": "[ REDACTED_DATA:ff... ]",
            "{length = 32, bytes = 0x00}": "[ REDACTED_DATA:00... ]",
            "{length = 32, bytes = 0x0000}": "[ REDACTED_DATA:00... ]",
            "{length = 32, bytes = 0x99}": "[ REDACTED_DATA:99... ]",
            "{length = 32, bytes = 0x999999}": "[ REDACTED_DATA:99... ]",
            "{length = 32, bytes = 0x00010203 44556677 89898989 abcdef01 ... aabbccdd eeff1234 }":
                "[ REDACTED_DATA:00... ]",
            "My data is: <01234567 89a23def 23234567 89ab1223>": "My data is: [ REDACTED_DATA:01... ]",
            "My data is <12345670 89a23def 23234567 89ab1223> their data is <87654321 89ab1234>":
                "My data is [ REDACTED_DATA:12... ] their data is [ REDACTED_DATA:87... ]"
        ]

        for (input, expectedOutput) in testCases {
            XCTAssertEqual(
                stripDate(fromRawMessage: format(input)),
                expectedOutput,
                "Failed redaction: \(input)"
            )
        }
    }

    func testIOS13AndHigherDataScrubbed() {
        let testCases: [String: String] = [
            "{length = 32, bytes = 0x01}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x012345}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x01234567}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a2}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23d}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def23}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def2323}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def232345}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def23234567}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def2323456789}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def2323456789ab}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def2323456789ab12}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0x0123456789a23def2323456789ab1234}": "[ REDACTED_DATA:01... ]",
            "{length = 32, bytes = 0xaa}": "[ REDACTED_DATA:aa... ]",
            "{length = 32, bytes = 0xaaaaaaaa}": "[ REDACTED_DATA:aa... ]",
            "{length = 32, bytes = 0xff}": "[ REDACTED_DATA:ff... ]",
            "{length = 32, bytes = 0xffff}": "[ REDACTED_DATA:ff... ]",
            "{length = 32, bytes = 0x00}": "[ REDACTED_DATA:00... ]",
            "{length = 32, bytes = 0x0000}": "[ REDACTED_DATA:00... ]",
            "{length = 32, bytes = 0x99}": "[ REDACTED_DATA:99... ]",
            "{length = 32, bytes = 0x999999}": "[ REDACTED_DATA:99... ]",
            "My data is: {length = 32, bytes = 0x0123456789a23def2323456789ab1223}":
                "My data is: [ REDACTED_DATA:01... ]",
            "My data is {length = 32, bytes = 0x1234567089a23def2323456789ab1223} their data is {length = 16, bytes = 0x8765432189ab1234}":
                "My data is [ REDACTED_DATA:12... ] their data is [ REDACTED_DATA:87... ]"
        ]

        for (input, expectedOutput) in testCases {
            XCTAssertEqual(
                stripDate(fromRawMessage: format(input)),
                expectedOutput,
                "Failed redaction: \(input)"
            )
        }
    }

    func testDataScrubbed_lazyFormatted() {
        let testCases: [Data: String] = [
            .init([0]): "[ REDACTED_DATA:00... ]",
            .init([0, 0, 0]): "[ REDACTED_DATA:00... ]",
            .init([1]): "[ REDACTED_DATA:01... ]",
            .init([1, 2, 3, 0x10, 0x20]): "[ REDACTED_DATA:01... ]",
            .init([0xff]): "[ REDACTED_DATA:ff... ]",
            .init([0xff, 0xff, 0xff]): "[ REDACTED_DATA:ff... ]"
        ]

        for (inputData, expectedOutput) in testCases {
            let input = (inputData as NSData).description
            XCTAssertEqual(
                stripDate(fromRawMessage: format(input)),
                expectedOutput,
                "Failed redaction: \(input)"
            )
        }
    }

    func testPhoneNumbersScrubbed() {
        let phoneStrings: [String] = [
            "+15557340123",
            "+447700900123",
            "+15557340123 somethingsomething +15557340123"
        ]
        let expectedOutput = "My phone number is [ REDACTED_PHONE_NUMBER:xxx123 ]"

        for phoneString in phoneStrings {
            let result = format("My phone number is \(phoneString)")
            XCTAssertTrue(result.contains(expectedOutput), "Failed to redact phone string: \(phoneString)")
            XCTAssertFalse(result.contains(phoneString), "Failed to redact phone string: \(phoneString)")
        }
    }

    func testNotScrubbed() {
        let input = "Some unfiltered string"
        let result = format(input)
        XCTAssertEqual(stripDate(fromRawMessage: result), input, "Shouldn't touch this string")
    }

    func testIPAddressesScrubbed() {
        let valueMap: [String: String] = [
            "0.0.0.0": "[ REDACTED_IPV4_ADDRESS:...0 ]",
            "127.0.0.1": "[ REDACTED_IPV4_ADDRESS:...1 ]",
            "255.255.255.255": "[ REDACTED_IPV4_ADDRESS:...255 ]",
            "1.2.3.4": "[ REDACTED_IPV4_ADDRESS:...4 ]"
        ]
        let messageFormats: [String] = [
            "a%@b",
            "http://%@",
            "http://%@/",
            "%@ and %@ and %@",
            "%@",
            "%@ %@",
            "no ip address!",
            ""
        ]

        for (ipAddress, redactedIpAddress) in valueMap {
            for messageFormat in messageFormats {
                let input = messageFormat.replacingOccurrences(of: "%@", with: ipAddress)
                let result = format(input)
                let expectedOutput = messageFormat.replacingOccurrences(of: "%@", with: redactedIpAddress)
                XCTAssertEqual(
                    stripDate(fromRawMessage: result),
                    expectedOutput,
                    "Failed to redact IP address input: \(input)"
                )
                XCTAssertFalse(
                    result.contains(ipAddress),
                    "Failed to redact IP address input: \(input)"
                )
            }
        }
    }

    func testUUIDsScrubbed_Random() {
        let expectedOutput = "My UUID is [ REDACTED_UUID:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"

        for _ in (1...10) {
            let uuid = UUID().uuidString
            let result = format("My UUID is \(uuid)")
            XCTAssertTrue(result.contains(expectedOutput), "Failed to redact UUID string: \(uuid)")
            XCTAssertFalse(result.contains(uuid), "Failed to redact UUID string: \(uuid)")
        }
    }

    func testUUIDsScrubbed_Specific() {
        let uuid = "BAF1768C-2A25-4D8F-83B7-A89C59C98748"
        let result = format("My UUID is \(uuid)")
        XCTAssertEqual(
            stripDate(fromRawMessage: result),
            "My UUID is [ REDACTED_UUID:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx748 ]",
            "Failed to redact UUID string: \(uuid)"
        )
        XCTAssertFalse(result.contains(uuid), "Failed to redact UUID string: \(uuid)")
    }

    func testTimestampsNotScrubbed() {
        // A couple sample messages from our logs
        let timestamp = Date.ows_millisecondTimestamp()
        let testCases: [String: String] = [
            // No change:
            "Sending message: TSOutgoingMessage, timestamp: \(timestamp)": "Sending message: TSOutgoingMessage, timestamp: \(timestamp)",
            // Leave timestamp, but UUID and phone number should be redacted
            "attempting to send message: TSOutgoingMessage, timestamp: \(timestamp), recipient: <SignalServiceAddress phoneNumber: +12345550123, uuid: BAF1768C-2A25-4D8F-83B7-A89C59C98748>":
                "attempting to send message: TSOutgoingMessage, timestamp: \(timestamp), recipient: <SignalServiceAddress phoneNumber: [ REDACTED_PHONE_NUMBER:xxx123 ], uuid: [ REDACTED_UUID:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx748 ]>"
        ]

        for (input, expectedOutput) in testCases {
            XCTAssertEqual(
                stripDate(fromRawMessage: format(input)),
                expectedOutput,
                "Failed redaction: \(input)"
            )
        }
    }

    func testLongHexStrings() {
        let testCases: [String: String] = [
            "": "",
            "01": "01",
            "0102": "0102",
            "010203": "010203",
            "01020304": "01020304",
            "0102030405": "0102030405",
            "010203040506": "010203040506",
            "01020304050607": "[ REDACTED_HEX:...607 ]",
            "0102030405060708": "[ REDACTED_HEX:...708 ]",
            "010203040506070809": "[ REDACTED_HEX:...809 ]",
            "010203040506070809ab": "[ REDACTED_HEX:...9ab ]",
            "010203040506070809abcd": "[ REDACTED_HEX:...bcd ]"
        ]

        for (input, expectedOutput) in testCases {
            XCTAssertEqual(
                stripDate(fromRawMessage: format(input)),
                expectedOutput,
                "Failed redaction: \(input)"
            )
        }
    }
}
