import Foundation
import SwiftyJSON

public class SimpleNetwork: Network {
    
    private var session: URLSession
    private var url: String
    private var headers: Dictionary<String, String>
    
    init(session: URLSession, url: String, headers: Dictionary<String, String>) {
        self.session = session
        self.url = url
        self.headers = headers
    }
    
    public func call(method: String, params: ParameterType) throws -> Data {
        return try session.data(
            from: URLPostRequest(
                url: URL(string: url + method)!,
                body: JSON(
                    dictionary: params.toJSON()!
                    )
                    .rawData(),
                    headers: headers
                ).toURLRequest()
        )
    }
    
}
