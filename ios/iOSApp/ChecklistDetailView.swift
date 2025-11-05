import SwiftUI

struct ChecklistDetailView: View {
    @ObservedObject var store: ChecklistStore
    let listID: UUID

    @State private var newFieldName: String = ""
    @State private var showCompletedAlert: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var lastCheckedCount: Int = 0

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
        return !fields.isEmpty && fields.allSatisfy(\.isChecked)
    }

    private var checkedCount: Int {
        guard let idx = checklistIndex else { return 0 }
        return store.lists[idx].fields.count(where: { $0.isChecked })
    }

    var body: some View {
        Group {
            if let list = listBinding {
                ZStack {
                    AppTheme.backgroundGradient
                        .ignoresSafeArea()

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
                                    TextField("Field name", text: $field.name)
                                } else {
                                    Toggle(isOn: $field.isChecked) {
                                        Text(field.name)
                                    }
                                    .toggleStyle(TileToggleStyle())
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorHiddenCompat()
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
                    .listStyle(.plain)
                    .scrollContentBackgroundHidden()
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .tintIfAvailable(AppTheme.navItemColor)
                .accentColor(AppTheme.navItemColor)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(list.wrappedValue.name)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.black)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            editMode = isEditing ? .inactive : .active
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                                .foregroundColor(AppTheme.navItemColor)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let done = checkedCount
                        let total = list.wrappedValue.fields.count
                        Text("\(done)/\(total)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .alert(isPresented: Binding(get: { !isEditing && showCompletedAlert }, set: { showCompletedAlert = $0 })) {
                    Alert(title: Text("Checklist Completed"), message: Text("All items are checked."), dismissButton: .default(Text("OK")))
                }
                .onAppear { lastCheckedCount = checkedCount }
                .onChange(of: checkedCount) { newCount in
                    // Only show when not editing and the number of checked items increased
                    if !isEditing, allChecked, newCount > lastCheckedCount {
                        showCompletedAlert = true
                    }
                    lastCheckedCount = newCount
                }
                .onChange(of: isEditing) { editing in
                    if editing { showCompletedAlert = false }
                }
                .environment(\.editMode, $editMode)
                .onAppear {
                    UINavigationBar.appearance().tintColor = AppTheme.navItemUIColor
                    UIBarButtonItem.appearance().tintColor = AppTheme.navItemUIColor
                }
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
