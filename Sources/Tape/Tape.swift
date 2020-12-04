//
//  Tape.swift
//  VideoTestiOS
//
//  Created by Dr. Brandon Wiley on 10/20/20.
//

import Foundation
import Datable

public typealias Timestamp = UInt64

public enum TapeType: UInt8
{
    case audioType = 0
    case videoType = 1
    case suspendAudioType = 2
    case suspendVideoType = 3
    case takeSpotlightType = 4
    case releaseSpotlightType = 5
    case playType = 6
    case pauseType = 7
    case unpauseType = 8
}

public enum Tape
{
    case audio(Timestamp, Data)
    case video(Timestamp, Data)
    case suspendAudio
    case suspendVideo
    case takeSpotlight
    case releaseSpotlight
    case play(URL)
    case pause
    case unpause
}

extension TapeType: MaybeDatable
{
    public init?(data: Data)
    {
        guard let uint8 = data.uint8 else {return nil}
        self.init(rawValue: uint8)
    }

    public var data: Data
    {
        return self.rawValue.data
    }
}

extension Tape: MaybeDatable
{
    public init?(data: Data)
    {
        let typeByte = Data(data[0..<1])
        let rest = Data(data[1...])

        guard let type = TapeType(data: typeByte) else {return nil}
        switch type
        {
            case .audioType:
                let timestamp = rest[0..<8]
                let frames = rest[8...]
                self = .audio(timestamp.uint64!, frames)

            case .videoType:
                let timestamp = rest[0..<8]
                let frames = rest[8...]
                self = .video(timestamp.uint64!, frames)

            case .suspendAudioType:
                self = .suspendAudio

            case .suspendVideoType:
                self = .suspendVideo

            case .takeSpotlightType:
                self = .takeSpotlight

            case .releaseSpotlightType:
                self = .releaseSpotlight

            case .playType:
                let urlString = rest.string
                guard let url = URL(string: urlString) else
                {
                    return nil
                }
                self = .play(url)

            case .pauseType:
                self = .pause

            case .unpauseType:
                self = .unpause
        }
    }

    public var data: Data
    {
        var result: Data = Data()

        switch self
        {
            case .audio(let timestamp, let data):
                result.append(TapeType.audioType.data)
                result.append(timestamp.data)
                result.append(UInt64(data.count).data)
                result.append(data)

            case .video(let timestamp, let data):
                result.append(TapeType.videoType.data)
                result.append(timestamp.data)
                result.append(UInt64(data.count).data)
                result.append(data)

            case .suspendAudio:
                result.append(TapeType.suspendAudioType.data)

            case .suspendVideo:
                result.append(TapeType.suspendVideoType.data)

            case .takeSpotlight:
                result.append(TapeType.takeSpotlightType.data)

            case .releaseSpotlight:
                result.append(TapeType.releaseSpotlightType.data)

            case .play(let url):
                result.append(TapeType.playType.data)
                let urlString = url.absoluteString
                let urlData = urlString.data
                result.append(UInt64(urlData.count).data)
                result.append(urlData)

            case .pause:
                result.append(TapeType.pauseType.data)

            case .unpause:
                result.append(TapeType.unpauseType.data)
        }

        return result
    }
}
