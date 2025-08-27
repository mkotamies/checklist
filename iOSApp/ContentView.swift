import SwiftUI

struct ContentView: View {
    @StateObject private var store = ChecklistStore()
    @State private var newFieldName: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                HStack {
                    TextField("Add new field", text: $newFieldName, onCommit: addField)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add", action: addField)
                        .disabled(newFieldName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding([.horizontal, .top])

                List {
                    ForEach($store.fields) { $field in
                        Toggle(field.name, isOn: $field.isChecked)
                    }
                    .onDelete(perform: store.delete)
                    .onMove(perform: store.move)
                }
            }
            .navigationTitle("Checklist")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Checked: \(store.fields.filter { $0.isChecked }.count)/\(store.fields.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func addField() {
        store.addField(name: newFieldName)
        newFieldName = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
