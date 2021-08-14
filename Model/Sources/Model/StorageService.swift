import Foundation
import GRDB

public final class StorageService {
    public static let shared: StorageService = {
        try! StorageService(url: StorageService.url)
    }()

    let databaseWriter: DatabaseWriter
    let publicationQueue = DispatchQueue(label: "StorageService")

    convenience init(url: URL) throws {
        let databasePool = try DatabaseQueue(path: url.path, configuration: Configuration())
        try databasePool.erase()
        try self.init(databaseWriter: databasePool)
    }

    private init(databaseWriter: DatabaseWriter) throws {
        self.databaseWriter = databaseWriter

        try migrate()
    }

    static var url: URL {
        let appSupport = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return appSupport.appendingPathComponent("db.sqlite")
    }
}
