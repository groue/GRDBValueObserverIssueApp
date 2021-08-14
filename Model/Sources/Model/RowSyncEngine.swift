import Combine
import Foundation
import GRDB

public struct Services {
    public let storage: StorageService
}

public final class RowSyncEngine {
    @Published public var activePages: Set<Int> = []
    @Published public var activeLayer = "public"
    @Published public var hiddenUserIDs: Set<String> = []

    private let services: Services
    private var cancellable: AnyCancellable?

    public init(services: Services) {
        self.services = services
    }
}

public extension RowSyncEngine {
    func addRows(_ rows: [Row], layer: String, overridingRevision: Int? = nil) {
        let groupedRows = Dictionary(grouping: rows) { completeRow in
            RowsKey(
                page: completeRow.pageNumber,
                layer: layer
            )
        }
        for (key, rows) in groupedRows {
            services.storage.databaseWriter.asyncWrite({ database in
                for row in rows {
                    try RowRecord(id: row.id, page: key.page, layer: key.layer, userID: row.userID, payload: row)
                        .insert(database)
                }
            }) { _, result in
                if case .failure(let error) = result {
                    print(error)
                }
            }
        }
    }

    func deleteAllRows() {
        do {
            _ = try services.storage.databaseWriter.write(RowRecord.deleteAll)
        } catch {
            print(error)
        }
    }

    func observeRows() -> AnyPublisher<[Event], Never> {
        return changes()
            .scan(into: [Int: Set<String>]()) { accumulator, change -> [Event] in
                var result = [Event]()
                for _ in 0..<100 {
                    switch change {
                    case .activeLayer:
                        let removedRowIDs = accumulator.values.reduce(into: [], +=)
                        if !removedRowIDs.isEmpty {
                            result.append(.removed(removedRowIDs))
                        }

                        accumulator = [:]
                    case .visibleRows(let page, let rows):
                        let previousIDs = accumulator[page, default: []]
                        let currentIDs = rows.map(\.id)

                        let removedRowIDs = previousIDs.subtracting(currentIDs)
                        if !removedRowIDs.isEmpty {
                            result.append(.removed(Array(removedRowIDs)))
                        }
                        let addedRows = rows.filter { !previousIDs.contains($0.id) }
                        if !addedRows.isEmpty {
                            result.append(.added(addedRows))
                        }

                        accumulator[page] = Set(currentIDs)
                    }
                }

                return result
            }
            .eraseToAnyPublisher()
    }

    func changes() -> AnyPublisher<Change, Never> {
        ValueObservation
            .tracking { database in
                try RowRecord.all()
                    .fetchAll(database)
                    .map(\.payload)
            }
            .print()
            .removeDuplicates()
            .publisher(in: services.storage.databaseWriter, scheduling: .async(onQueue: services.storage.publicationQueue))
            .replaceError(with: [])
            .map { .visibleRows(page: 1, $0) }
            .eraseToAnyPublisher()
    }

    enum Change {
        case activeLayer
        case visibleRows(page: Int, [Row])
    }

    enum Event {
        case added([Row])
        case removed([Row.ID])
    }
}

struct RowsKey: Hashable {
    let page: Int
    let layer: String
}

public extension Publisher {
    func scan<T, O>(into initialResult: T, _ nextPartialOutput: @escaping (inout T, Output) -> O) -> AnyPublisher<O, Failure> {
        scan((initialResult, nil)) { accumulator, value in
            var result = accumulator.0
            let output = nextPartialOutput(&result, value)
            return (result, output)
        }
        .compactMap { $1 }
        .eraseToAnyPublisher()
    }
}
