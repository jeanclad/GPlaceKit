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

// TODO: 키교체
let apiKey = "AIzaSyDvHzmSse2t1zJd4-idzQIDd-Wdf7PecdQ"
//tour "AIzaSyD5A7JxIDSHIS3m_CkBJf_rdmiBXcKk5pI"
//jeanclad "AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs"

fileprivate enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

fileprivate enum StatusCode: Int {
    // MARK: 2xx codes
    case OK                         = 200
    
    // MARK: 9xx codes
    case NotFoundURL                = 999
    case NotKwonResponse            = 998
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

internal class HTTPService: NSObject {
    static let shared = HTTPService()
    
    fileprivate func request(url: URL,
                             params: [String: String]? = nil,
                             method: HTTPMethod,
                             completion: @escaping successClosure,
                             failure: @escaping failureClosure) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error occured: \(String(describing: error))")
                let error = NSError(domain: NSURLErrorDomain,
                                    code: StatusCode.NotFoundURL.rawValue,
                                    userInfo: nil)
                failure(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == StatusCode.OK.rawValue {
                    let result = Response(response: httpResponse, data: data, url: response?.url)
                    completion(result)
                    return
                }
                
                let error = NSError(domain: NSURLErrorDomain,
                                    code: NSURLErrorUnknown,
                                    userInfo: ["statusCode" : httpResponse.statusCode])
                
                failure(error)
                return
            }
            
            let error = NSError(domain: NSURLErrorDomain,
                                code: StatusCode.NotKwonResponse.rawValue,
                                userInfo: nil)
            failure(error)
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
                                code: StatusCode.NotFoundURL.rawValue,
                                userInfo: nil)
            
            failure(error)
            return
        }
        
        request(url: url, method: .GET, completion: { (response) in
            completion(response)
        }) { (error) in
            failure(error)
        }
    }
    
    // TOOD: 차후 확장
    internal func fetchPOST(urlString: String,
                            params: [String: String],
                            completion: @escaping successClosure,
                            failure: @escaping failureClosure) {
        
    }
    
    // TOOD: 차후 확장
    internal func fetchPUT(urlString: String,
                           completion: @escaping successClosure,
                           failure: @escaping failureClosure) {
        
    }
    
    // TOOD: 차후 확장
    internal func fetchDELETE(urlString: String,
                              completion: @escaping successClosure,
                              failure: @escaping failureClosure) {
        
    }
}
