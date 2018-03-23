import Foundation

public protocol Network {

    func call(method: String, params: ParameterType) throws -> Data

}
