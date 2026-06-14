import Foundation

@MainActor
final class HistoryService: ObservableObject {
    @Published private(set) var items: [OperationHistoryItem] = []

    private let defaultsKey = "operationHistory"

    func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([OperationHistoryItem].self, from: data) else {
            items = OperationHistoryItem.mocks
            return
        }

        items = decoded
    }

    func add(_ item: OperationHistoryItem) {
        items.insert(item, at: 0)
        save()
    }

    func delete(_ item: OperationHistoryItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
