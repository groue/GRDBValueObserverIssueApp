import Combine
import Foundation
import GRDB

struct RowRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    let id: String
    let page: Int
    let layer: String
    let userID: String?
    let payload: Row

    static var databaseTableName: String {
        "row"
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let page = Column(CodingKeys.page)
        static let layer = Column(CodingKeys.layer)
        static let userID = Column(CodingKeys.userID)
        static let payload = Column(CodingKeys.payload)
    }
}
