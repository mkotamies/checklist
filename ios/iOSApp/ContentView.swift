import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = ChecklistStore()
    @State private var showingNewListSheet = false
    @State private var newListName: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                GeometryReader { proxy in
                    let spacing: CGFloat = 16
                    let columnsCount = 2
                    let totalSpacing = spacing * CGFloat(columnsCount - 1)
                    let horizontalPadding = spacing * 2
                    let availableWidth = proxy.size.width - totalSpacing - horizontalPadding
                    let itemSize = floor(availableWidth / CGFloat(columnsCount))

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            let columns = Array(repeating: GridItem(.fixed(itemSize), spacing: spacing, alignment: .top), count: columnsCount)
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(store.lists) { list in
                                    NavigationLink(destination: ChecklistDetailView(store: store, listID: list.id)) {
                                        VStack(alignment: .leading, spacing: 8) {
                                        Text(list.name)
                                                .font(.system(size: 16, weight: .regular))
                                                .foregroundColor(AppTheme.tileText)
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.8)

                                            let total = list.fields.count
                                            let done = list.fields.filter { $0.isChecked }.count
                                            Text("\(done)/\(total)")
                                                .foregroundColor(.black.opacity(0.5))
                                                .font(.caption)
                                        }
                                        .padding(16)
                                        .frame(width: itemSize, height: itemSize, alignment: .topLeading)
                                        .background(AppTheme.tileBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, spacing)
                        .padding(.vertical, spacing)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Checklists")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewListSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
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
