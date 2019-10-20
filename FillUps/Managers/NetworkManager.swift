//
//  NetworkManager.swift
//  FillUps
//
//  Created by Keshav Bansal on 08/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import Foundation

public typealias DataCallback = ((Data) -> ())
public typealias ErrorCallback = ((String) -> ())

class NetworkManager {
    
    static let shared = NetworkManager()
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        return session
    }()

    // func gets JSON data and maps it to an object confirming to Codable.
    public func fetchJSONData<A: Codable>(forUrl url: String, completion: @escaping (A) -> Void, error: ErrorCallback?) {
        _ = self.loadData(fromUrl: url, completion: { (data) in
            do {
                let objects = try JSONDecoder().decode(A.self, from: data)
                completion(objects)
            } catch let jsonErr {
                print("Failed to decode json: \(jsonErr)")
                error?("Failed to decode json: \(jsonErr)")
            }
        }, errorCallback: error)
    }
    
    // Generic function to download any type of data
    public func loadData(fromUrl urlString: String, completion: @escaping DataCallback, errorCallback: ErrorCallback?) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let dataTask = self.urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response, error == nil {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                    if statusCode == 200 {
                        // API success
                        print("Success getting response for URL: \(urlString)")
                        completion(data)
                    } else {
                        errorCallback?("Unable to load resource for URL: \(urlString). Status Code \(statusCode)")
                    }
                } else if let error = error {
                    errorCallback?(error.localizedDescription)
                } else {
                    errorCallback?("Unable to load resource for URL: \(urlString)")
                }
            })
            dataTask.resume()
        }
    }
}
