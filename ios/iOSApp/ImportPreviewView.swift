import SwiftUI

struct ImportPreviewView: View {
    let checklists: [Checklist]
    let existingNames: Set<String>
    let onImport: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(checklists) { checklist in
                        HStack {
                            Text(checklist.name)
                                .fontWeight(.medium)
                            Spacer()
                            if existingNames.contains(checklist.name) {
                                Text("update")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.15))
                                    .cornerRadius(4)
                            } else {
                                Text("new")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.15))
                                    .cornerRadius(4)
                            }
                            Text("\(checklist.fields.count) items")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Checklists to import")
                }
            }
            .navigationTitle("Import Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import", action: onImport)
                }
            }
        }
    }
}
