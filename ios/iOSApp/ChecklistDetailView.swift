import SwiftUI
import UIKit

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
                        Section {
                            // Hide quick add row while editing
                            if !isEditing {
                                // Quick add row at the very top (same section as items to keep spacing consistent)
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(AppTheme.tileText.opacity(0.35))
                                        .imageScale(.large)
                                    FocusableTextField(
                                        text: $newFieldName,
                                        isFirstResponder: true,
                                        placeholder: "Add new item",
                                        onCommit: addField,
                                    )
                                }
                                .tileStyle()
                                .listRowBackground(Color.clear)
                                .listRowSeparatorHiddenCompat()
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            }

                            ForEach(list.fields) { $field in
                                if isEditing {
                                    HStack(spacing: 12) {
                                        FocusableTextField(
                                            text: $field.name,
                                            isFirstResponder: false,
                                            placeholder: "Field name",
                                        )
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(AppTheme.tileText)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(AppTheme.tileBackground)
                                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3),
                                    )
                                    .listRowSeparatorHiddenCompat()
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                } else {
                                    Toggle(isOn: $field.isChecked) {
                                        Text(field.name)
                                    }
                                    .toggleStyle(TileToggleStyle())
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorHiddenCompat()
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
                    .listRowSpacingCompat(8)
                    .scrollContentBackgroundHidden()
                    .simultaneousGesture(TapGesture().onEnded { dismissKeyboard() })
                    .gesture(DragGesture().onChanged { _ in dismissKeyboard() })
                    .padding(.top, 16)
                    .padding(.horizontal, isEditing ? 16 : 0)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .tintIfAvailable(AppTheme.navItemColor)
                .accentColor(AppTheme.navItemColor)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        if isEditing {
                            TextField("Name", text: list.name)
                                .font(.system(size: 22, weight: .regular))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        } else {
                            Text(list.wrappedValue.name)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let done = checkedCount
                        let total = list.wrappedValue.fields.count
                        Text("\(done)/\(total)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    // Pencil icon button on trailing side (rightmost)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            editMode = isEditing ? .inactive : .active
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                                .imageScale(.medium)
                                .accessibilityLabel(isEditing ? "Done" : "Edit")
                        }
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
        // Insert at top so new item appears right under the input row
        store.lists[idx].fields.insert(Field(name: name), at: 0)
        newFieldName = ""
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - FocusableTextField for iOS 14+

private struct FocusableTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onCommit: (() -> Void)?
        init(text: Binding<String>, onCommit: (() -> Void)?) {
            self.text = text
            self.onCommit = onCommit
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            onCommit?()
            return true
        }

        func textFieldDidEndEditing(_: UITextField) {
            onCommit?()
        }
    }

    @Binding var text: String
    var isFirstResponder: Bool
    var placeholder: String = "Field name"
    var onCommit: (() -> Void)?

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.delegate = context.coordinator
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context _: Context) {
        if uiView.text != text { uiView.text = text }
        if isFirstResponder, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onCommit: onCommit)
    }
}
