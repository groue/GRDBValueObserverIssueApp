import GRDB

extension StorageService {
    func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("2020-08-27") { database in
            try database.create(table: "row") { definition in
                definition.column("id", .text).primaryKey().notNull()
                definition.column("page", .integer).notNull()
                definition.column("layer", .text).notNull()
                definition.column("userID", .text)
                definition.column("payload", .text).notNull()
            }

            try database.create(table: "rowCommand") { definition in
                definition.column("rowID", .text).primaryKey().notNull().references("row", onDelete: .cascade)
                definition.column("id", .blob).notNull()
                definition.column("kind", .text).notNull()
                definition.column("wasRejected", .boolean).notNull()
            }

            try database.create(table: "rowResource") { definition in
                definition.column("rowID", .text).notNull().references("row", onDelete: .cascade)
                definition.column("url", .text)
                definition.column("payload", .blob).notNull()
            }
        }

        try migrator.migrate(databaseWriter)
    }
}
