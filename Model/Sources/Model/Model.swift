import Combine
import Foundation
import GRDB

#if DEBUG
#error("This project must be run in Release (optimized) to trigger the error")
#endif

public class Model: ObservableObject {
    @Published public var rows: [Row] = []

    private var cancellables = [AnyCancellable]()

    public init() {
    }

    public var canStart: Bool {
        rows.count == 0
    }

    public var progress: Double {
        Double(min(rowCountMaximum, rows.count)) / Double(rowCountMaximum)
    }

    public var rowCountMaximum: Int {
        200
    }

    public func start() {
        let services = Services(storage: StorageService.shared)
        let rowSyncEngine = RowSyncEngine(
            services: services
        )
        rowSyncEngine.activePages = [1]
        cancellables.append(rowSyncEngine.observeRows().receive(on: DispatchQueue.main).sink { events in
            self.updateProgress(events)
        })

        var iteration = 0
        rowSyncEngine.deleteAllRows()
        let cancellable = DispatchQueue.main.schedule(after: DispatchQueue.main.now, interval: .milliseconds(20), tolerance: .milliseconds(20), options: nil) {
            self.performIteration(&iteration, rowSyncEngine: rowSyncEngine)
        }

        cancellables.append(AnyCancellable { cancellable.cancel() })
    }

    func performIteration(_ iteration: inout Int, rowSyncEngine: RowSyncEngine) {
        iteration += 1
        if iteration >= rowCountMaximum {
            stop(rowSyncEngine: rowSyncEngine)
        }

        rowSyncEngine.addRows([Row()], layer: "public")
    }

    func updateProgress(_ events: [RowSyncEngine.Event]) {
        for event in events {
            switch event {
            case .added(let newRows):
                self.rows.append(contentsOf: newRows)
            case .removed(let removedRows):
                let ids = Set(removedRows)
                self.rows.removeAll { ids.contains($0.id) }
            }
        }
    }

    func stop(rowSyncEngine: RowSyncEngine) {
        rowSyncEngine.deleteAllRows()
        for cancellable in cancellables {
            cancellable.cancel()
            cancellables.removeAll()
        }
        rows = []
    }
}
