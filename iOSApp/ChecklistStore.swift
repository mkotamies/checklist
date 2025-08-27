import Foundation
import Combine

struct Field: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var isChecked: Bool = false
}

final class ChecklistStore: ObservableObject {
    @Published var fields: [Field] = [] {
        didSet { save() }
    }

    private let fileURL: URL

    init(filename: String = "checklist.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent(filename)
        load()
    }

    func addField(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !fields.contains(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        fields.append(Field(name: trimmed))
    }

    func delete(at offsets: IndexSet) {
        fields.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        fields.move(fromOffsets: source, toOffset: destination)
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Field].self, from: data)
            self.fields = decoded
        } catch {
            // If no file yet, start empty
            self.fields = []
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(fields)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // In a simple app, we silently ignore write errors
            // Could add logging here if desired
        }
    }
}

