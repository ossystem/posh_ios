//
//  CommonQuestion.swift
//  TelemedDoctor
//
//  Created by Ivan Grachev on 02/03/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import ObjectMapper

class CommonQuestion: ImmutableMappable {
    
    var question = ""
    var answer = ""
    
    required init(map: Map) throws {
        question = try map.value("question")
        answer = try map.value("answer")
    }
    
    func mapping(map: Map) {
        question <- map["question"]
        answer <- map["answer"]
    }
    
}

class FAQuestions: ResponseType {
    
    var questions: [CommonQuestion]
    
    required init(map: Map) throws {
        questions = try map.value("faq")
    }
}
