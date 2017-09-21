//
//  HTTPService.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 21..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

public typealias successClosure = (Response) -> ()
public typealias failureClosure = (Error) -> ()

fileprivate enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

public struct Response {
    public let response: HTTPURLResponse
    public let data: Data?
    public var url: URL?
    
    init(response: HTTPURLResponse, data: Data? = nil, url: URL? = nil ) {
        self.response = response
        self.data = data
        self.url = url
    }
}

fileprivate class HTTPService: NSObject {
    static let shared = HTTPService()
    
    fileprivate func request(url: URL,
                             method: HTTPMethod,
                             completion: @escaping successClosure,
                             failure: @escaping failureClosure) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // TODO: POST의 header를 파라미터로 받아서 처리하도록
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error occured: \(String(describing: error))")
                completion(nil)
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    print("Error: JSON Deserialized")
                    completion(nil)
                    return
                }
                
                let chart = json?.value(forKeyPath: "feed.entry") as? [NSDictionary]
                completion(chart)
                return
            }
            
            completion(nil)
            return
        }
        task.resume()
    }
    
    internal func fetchGET(urlString: String,
                           completion: @escaping successClosure,
                           failure: @escaping failureClosure) {
        // fetch the data
        guard let url = URL(string: urlString) else {
            print("URL is nil")
            let error = NSError(domain: NSURLErrorDomain,
                                code: -999,
                                userInfo: nil)
            
            failure(error)
            return
        }
        
        request(url: url, method: .GET, completion: { (response) in
            
        }) { (error) in
            let error = NSError(domain: NSURLErrorDomain,
                                code: NSURLErrorUnknown,
                                userInfo: ["statusCode" : httpResponse.statusCode])
            failure(error)
        }
    }
    
    
}
