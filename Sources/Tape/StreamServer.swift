//
//  File.swift
//  
//
//  Created by Dr. Brandon Wiley on 12/3/20.
//

import Foundation
import Transmission

public class StreamServer
{
    let listener: Listener
    let queue: DispatchQueue = DispatchQueue(label: "StreamServer")

    var controllers: [StreamController] = []

    init(listener: Listener, callback: @escaping Callback)
    {
        self.listener = listener

        queue.async
        {
            self.receiveLoop(callback: callback)
        }
    }

    public convenience init?(port: Int, callback: @escaping Callback)
    {
        guard let listener = Listener(port: port) else {return nil}
        self.init(listener: listener, callback: callback)
    }

    public func receiveLoop(callback: @escaping Callback)
    {
        while true
        {
            let connection = listener.accept()
            let controller = StreamController(connection: connection, callback: callback)
            self.controllers.append(controller)
        }
    }
}
