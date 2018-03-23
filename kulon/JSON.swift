//
// Created by Timofey on 1/21/18.
//

import Foundation
import SwiftyJSON

fileprivate class InvalidTypeError<T>: DescribedError {

    private let json: JSON
    private let typeName: String
    init(json: JSON, expectedType: T.Type) {
        self.json = json
        self.typeName = String(describing: expectedType)
    }

    var description: String {
        return "Expected type was \(typeName) but it was actually \(String(describing: json.type))"
    }

}

extension JSON {

    init(dictionary: [String: Any]) {
        self.init(dictionary)
    }

    func int() throws -> Int {
        if let int = self.int {
            return int
        } else {
            throw InvalidTypeError(json: self, expectedType: Int.self)
        }
    }

    func string() throws -> String {
        if let string = self.string {
            return string
        } else {
            throw InvalidTypeError(json: self, expectedType: String.self)
        }
    }

}
