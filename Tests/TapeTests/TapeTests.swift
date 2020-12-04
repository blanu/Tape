import XCTest
@testable import Tape

final class TapeTests: XCTestCase
{
    func testClientServer()
    {
        let serverReceived = XCTestExpectation(description: "server received message")
        let clientReceived = XCTestExpectation(description: "client received message")

        let server = StreamServer(port: 1234)
        {
            (controller, tape) in

            controller.send(tape: Tape.pause)
            serverReceived.fulfill()
        }

        let client = StreamController(host: "127.0.0.1", port: 1234)
        {
            (controller, tape) in

            controller.send(tape: Tape.unpause)
            clientReceived.fulfill()
        }

        wait(for: [serverReceived, clientReceived], timeout: 60)
    }

    static var allTests = [
        ("testExample", testClientServer),
    ]
}
