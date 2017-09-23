//
//  GPlaceKitTests.swift
//  GPlaceKitTests
//
//  Created by jeanclad on 2017. 9. 21..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import XCTest
@testable import GPlaceKit

class GPlaceKitTests: XCTestCase {
    
    let waitTimeout: TimeInterval = 60
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchGETWithJson() {
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=플레이뮤지엄&language=ko&key=\(apiKey)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        HTTPService.shared.fetchGET(urlString: encoded_url!, completion: { (response) in
            if let data = response.data {
                do {
                    let JSON = try JSONSerialization.jsonObject(with: data,
                                                                options: .mutableContainers)
                    print("Data received : \(JSON)")
                    
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
            
            if let url = response.url {
                print("response finished: \(url)")
            }
            
            expectation.fulfill()
        }) { (error) in
            print("error happend in failure closure")
            XCTFail("error: \(error.localizedDescription )")
        }
        
        waitForExpectations(timeout: waitTimeout) { error in
            print("timedout after \(self.waitTimeout) with error:\(error?.localizedDescription ?? "")")
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
