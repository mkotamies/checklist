import Foundation
import Combine

struct Field: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var isChecked: Bool = false
}

struct Checklist: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var fields: [Field] = []
}

final class ChecklistStore: ObservableObject {
    @Published var lists: [Checklist] = [] {
        didSet { save() }
    }

    private let fileURL: URL

    init(filename: String = "checklists.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent(filename)
        load()
    }

    // MARK: - List operations
    func addList(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lists.append(Checklist(name: trimmed))
    }

    func deleteLists(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets)
    }

    func moveLists(from source: IndexSet, to destination: Int) {
        lists.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Persistence
    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Checklist].self, from: data)
            self.lists = decoded
        } catch {
            // Migration path: try to read legacy single-list file format ([Field])
            let legacyURL = fileURL.deletingLastPathComponent().appendingPathComponent("checklist.json")
            if let legacyData = try? Data(contentsOf: legacyURL), let legacyFields = try? JSONDecoder().decode([Field].self, from: legacyData) {
                self.lists = [Checklist(name: "My Checklist", fields: legacyFields)]
            } else {
                self.lists = []
            }
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(lists)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Ignored for simplicity
        }
    }
}
