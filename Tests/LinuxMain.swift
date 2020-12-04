import XCTest

import TapeTests

var tests = [XCTestCaseEntry]()
tests += TapeTests.allTests()
XCTMain(tests)
