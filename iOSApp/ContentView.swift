import SwiftUI

struct ContentView: View {
    @StateObject private var store = ChecklistStore()
    @State private var showingNewListSheet = false
    @State private var newListName: String = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(store.lists) { list in
                    NavigationLink(destination: ChecklistDetailView(store: store, listID: list.id)) {
                        HStack {
                            Text(list.name)
                            Spacer()
                            let total = list.fields.count
                            let done = list.fields.filter { $0.isChecked }.count
                            Text("\(done)/\(total)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: store.deleteLists)
                .onMove(perform: store.moveLists)
            }
            .navigationTitle("My Checklists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewListSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewListSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("List Name")) {
                            TextField("e.g. Trip Prep", text: $newListName)
                        }
                    }
                    .navigationTitle("New Checklist")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingNewListSheet = false; newListName = "" }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") { createList() }
                                .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }

    private func createList() {
        store.addList(name: newListName)
        newListName = ""
        showingNewListSheet = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

