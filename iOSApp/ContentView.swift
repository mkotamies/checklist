import SwiftUI

struct Field: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var isChecked: Bool = false
}

struct ContentView: View {
    @State private var fields: [Field] = [
        Field(name: "First Field"),
        Field(name: "Second Field"),
        Field(name: "Third Field")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach($fields) { $field in
                    Toggle(field.name, isOn: $field.isChecked)
                }
            }
            .navigationTitle("Checklist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Checked: \(fields.filter { $0.isChecked }.count)/\(fields.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
