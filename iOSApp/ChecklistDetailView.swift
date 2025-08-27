import SwiftUI

struct ChecklistDetailView: View {
    @ObservedObject var store: ChecklistStore
    let listID: UUID

    @State private var newFieldName: String = ""
    @State private var showCompletedAlert: Bool = false
    @State private var editMode: EditMode = .inactive

    private var isEditing: Bool { editMode.isEditing }

    private var checklistIndex: Int? {
        store.lists.firstIndex { $0.id == listID }
    }

    private var listBinding: Binding<Checklist>? {
        guard let idx = checklistIndex else { return nil }
        return $store.lists[idx]
    }

    private var allChecked: Bool {
        guard let idx = checklistIndex else { return false }
        let fields = store.lists[idx].fields
        return !fields.isEmpty && fields.allSatisfy { $0.isChecked }
    }

    private var checkedCount: Int {
        guard let idx = checklistIndex else { return 0 }
        return store.lists[idx].fields.filter { $0.isChecked }.count
    }

    var body: some View {
        Group {
            if let list = listBinding {
                List {
                    if isEditing {
                        Section(header: Text("List Name")) {
                            TextField("Name", text: list.name)
                        }
                        Section(header: Text("Add Field")) {
                            HStack {
                                TextField("New field name", text: $newFieldName, onCommit: addField)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add", action: addField)
                                    .disabled(newFieldName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }

                    Section {
                        ForEach(list.fields) { $field in
                            if isEditing {
                                Toggle(isOn: $field.isChecked) {
                                    TextField("Field name", text: $field.name)
                                }
                            } else {
                                Toggle(field.name, isOn: $field.isChecked)
                            }
                        }
                        .onDelete { offsets in
                            list.wrappedValue.fields.remove(atOffsets: offsets)
                        }
                        .onMove { from, to in
                            list.wrappedValue.fields.move(fromOffsets: from, toOffset: to)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle(list.wrappedValue.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let done = checkedCount
                        let total = list.wrappedValue.fields.count
                        Text("\(done)/\(total)")
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
                .environment(\.editMode, $editMode)
            } else {
                Text("List not found").foregroundColor(.secondary)
            }
        }
    }

    private func addField() {
        guard let idx = checklistIndex else { return }
        let name = newFieldName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        store.lists[idx].fields.append(Field(name: name))
        newFieldName = ""
    }
}
