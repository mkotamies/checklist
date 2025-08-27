import SwiftUI

struct ContentView: View {
    @StateObject private var store = ChecklistStore()
    @State private var newFieldName: String = ""
    @State private var showCompletedAlert: Bool = false

    private var allChecked: Bool {
        !store.fields.isEmpty && store.fields.allSatisfy { $0.isChecked }
    }

    private var checkedCount: Int { store.fields.filter { $0.isChecked }.count }

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
            .alert(isPresented: $showCompletedAlert) {
                Alert(title: Text("Checklist Completed"), message: Text("All items are checked."), dismissButton: .default(Text("OK")))
            }
            .onChange(of: checkedCount) { _ in
                if allChecked { showCompletedAlert = true }
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
