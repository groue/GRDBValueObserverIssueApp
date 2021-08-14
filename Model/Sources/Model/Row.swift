import Foundation

public struct Row: Codable, Equatable, Identifiable {
    public var id: String
    var rowType: Int
    var pageNumber: Int
    var version: String?
    var userID: String?
    var created: Date?
    var content: String?
    var values: [Float]?
    var childRows: [Row]?

    public init() {
        id = UUID().uuidString
        rowType = 0
        pageNumber = 1
        version = nil
        userID = nil
        content = nil
        values = [1,2,3,4,5,6,7,8,9,10,11,12]
        childRows = nil
    }
}
