//
//  WebSocketService.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation
import Combine

// Defines the types of network errors that can occur
enum NetworkError: Error {
    case badURL
    case networkProblem
    case decodingError
}

// Protocol for objects that will handle reconnection actions
protocol WebSocketServiceDelegate {
    func reconnect()
}

// Main service class for interacting with a WebSocket server
class WebSocketService: NSObject {
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private var continuousErrorCount = 0
    private var lastArgs: String = ""

    // Subjects for publishing updates to subscribers
    var orderBookUpdateSubject = PassthroughSubject<OrderBookUpdate, Never>()
    var recentTradesUpdateSubject = PassthroughSubject<RecentTradeUpdate, Never>()
    
    var delegate: WebSocketServiceDelegate?
    
    private let socketDelegateQueue = OperationQueue()

    // Initialize with a URL, defaults to Bitmex
    init(url: URL = URL(string: "wss://www.bitmex.com/realtime")!) {
        self.url = url
        socketDelegateQueue.name = "com.rwjk.AQXInterview.queue"
        super.init()
    }

    // Connects to the WebSocket server
    func connect() {

        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: socketDelegateQueue)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    // Disconnects from the WebSocket server
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    // Subscribes to a specific table and coin pair
    func subscribe(to table: String, coinPair: String) {
        lastArgs = "\(table):\(coinPair)"
        let message = WebSocketMessage(op: "subscribe",
                                       args: [lastArgs])
        do {
            let data = try JSONEncoder().encode(message)
            let jsonString = String(data: data, encoding: .utf8)!
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("WebSocket couldn’t send message because: \(error)")
                }
            }
        } catch {
            print("Error encoding WebSocketMessage: \(error)")
        }
    }

    // Subscribes to recent trades for a specific coin pair
    func subscribeRecentTrades(coinPair: String) {
        subscribe(to: "trade", coinPair: coinPair)
    }
    
    func unsubscribe() {
        // Construct the unsubscribe message
        let unsubscribeMessage: [String: Any] = [
            "op": "unsubscribe",
            "args": [lastArgs]
        ]
        
        // Convert the message to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: unsubscribeMessage) else {
            // Handle JSON serialization error
            return
        }
        
        // Send the unsubscribe message to the server
        webSocketTask?.send(.data(jsonData)) { error in
            if let error = error {
                // Handle send error
                print("Error sending unsubscribe message: \(error)")
            } else {
                // Unsubscribe message sent successfully
                print("Unsubscribed")
            }
        }
    }

    // Fetches list of coins from the server
    func getCoinList(completion: @escaping (Result<[CoinPair], NetworkError>) -> Void) {
        guard let url = URL(string: "https://www.bitmex.com/api/v1/instrument/active") else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.networkProblem))
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }
            
            do {
                let coinPairs = try JSONDecoder().decode([CoinPair].self, from: data)
                completion(.success(coinPairs))
            } catch {
                print("Error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // Continuously receives messages from the WebSocket server
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.continuousErrorCount += 1
                if self?.continuousErrorCount ?? 0 > 2 {
                    self?.handleContinuousErrors()
                    return
                }
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
            }
            
            self?.receiveMessage()
        }
    }
    
    // Handles incoming WebSocket messages
    private func handleWebSocketMessage(_ text: String) {
        DispatchQueue.main.async {
            if let data = text.data(using: .utf8) {
                if let orderBookUpdate = try? JSONDecoder().decode(OrderBookUpdate.self,
                                                                   from: data) {
                    self.orderBookUpdateSubject.send(orderBookUpdate)
                } else if let recentTradesUpdate = try? JSONDecoder().decode(RecentTradeUpdate.self,
                                                                             from: data) {
                    self.recentTradesUpdateSubject.send(recentTradesUpdate)
                } else {
                    print("ERROR decoding update")
                }
            }
        }
    }
    
    // Handles continuous errors by applying exponential backoff and trying to reconnect
    private func handleContinuousErrors() {
        let backoffInterval = pow(2, Double(continuousErrorCount))
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + backoffInterval) {
            self.delegate?.reconnect()
        }
    }
}

// WebSocket delegate methods for managing the WebSocket connection
extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("WebSocket did open")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task did complete with error: \(error)")
        } else {
            print("WebSocket task did complete")
        }
    }
}
