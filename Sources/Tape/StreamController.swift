//
//  StreamController.swift
//  VideoTestiOS
//
//  Created by Dr. Brandon Wiley on 10/19/20.
//

import Foundation
import Transmission

public typealias Callback = (StreamController, Tape) -> Void

public class StreamController
{
    let connection: Connection
    let queue: DispatchQueue = DispatchQueue(label: "StreamController")
    let id = UUID()

    init(connection: Connection, callback: @escaping Callback)
    {
        self.connection = connection

        queue.async
        {
            self.receiveLoop(callback: callback)
        }
    }

    public convenience init?(host: String, port: Int, callback: @escaping Callback)
    {
        guard let connection = Connection(host: host, port: port) else {return nil}
        self.init(connection: connection, callback: callback)
    }

    public func send(tape: Tape)
    {
        let data = tape.data
        let success = self.connection.write(data: data)
        if !success
        {
            print("Failed to send tape")
        }
    }

    public func receiveLoop(callback: Callback)
    {
        while true
        {
            guard let tape = parseTape() else {return}
            callback(self, tape)
        }
    }

    func parseTape() -> Tape?
    {
        guard let typeByte = self.connection.read(size: 1) else {return nil}
        guard let type = TapeType(data: typeByte) else {return nil}
        switch type
        {
            case .audioType:
                guard let timestampBytes = self.connection.read(size: 8) else {return nil}
                guard let timestamp = timestampBytes.uint64 else {return nil}

                guard let payloadLengthBytes = self.connection.read(size: 8) else {return nil}
                guard let payloadLength64 = payloadLengthBytes.uint64 else {return nil}
                let payloadLength = Int(payloadLength64)

                guard let payload = self.connection.read(size: payloadLength) else {return nil}

                return Tape.audio(timestamp, payload)

            case .videoType:
                guard let timestampBytes = self.connection.read(size: 8) else {return nil}
                guard let timestamp = timestampBytes.uint64 else {return nil}

                guard let payloadLengthBytes = self.connection.read(size: 8) else {return nil}
                guard let payloadLength64 = payloadLengthBytes.uint64 else {return nil}
                let payloadLength = Int(payloadLength64)

                guard let payload = self.connection.read(size: payloadLength) else {return nil}

                return Tape.video(timestamp, payload)

            case .suspendAudioType:
                return Tape.suspendAudio

            case .suspendVideoType:
                return Tape.suspendVideo

            case .takeSpotlightType:
                return Tape.takeSpotlight

            case .releaseSpotlightType:
                return Tape.releaseSpotlight

            case .playType:
                guard let payloadLengthBytes = self.connection.read(size: 8) else {return nil}
                guard let payloadLength64 = payloadLengthBytes.uint64 else {return nil}
                let payloadLength = Int(payloadLength64)

                guard let payload = self.connection.read(size: payloadLength) else {return nil}

                let urlString = payload.string
                guard let url = URL(string: urlString) else {return nil}

                return Tape.play(url)

            case .pauseType:
                return Tape.pause

            case .unpauseType:
                return Tape.unpause
        }
    }
}

extension StreamController: Equatable
{
    public static func == (lhs: StreamController, rhs: StreamController) -> Bool
    {
        return lhs.id == rhs.id
    }
}

extension StreamController: Hashable
{
    public func hash(into: inout Hasher)
    {
        into.combine(self.id)
    }
}
