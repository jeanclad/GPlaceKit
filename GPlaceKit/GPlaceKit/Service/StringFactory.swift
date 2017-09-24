//
//  StringFactory.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import Foundation

class StringFactory {
    internal func getTextJsonFail() -> String {
        return "올바른 형식의 데이터가 수신되지 않았습니다."
    }
    
    internal func getTextSeachableFail() -> String {
        return "올바른 검색어 형태가 아닙니다."
    }
    
    internal func getTextSeachableNone() -> String {
        return "검색결과가 없습니다.."
    }
    
    internal func getTextDetailFail() -> String {
        return "상세정보를 찾을수 없습니다."
    }
}
