# Markdown Import/Export Implementation Plan

**Goal:** Add import/export buttons to home screen that copy all checklists as markdown to clipboard and import markdown from clipboard with preview.

**Approach:** Create a `MarkdownParser.swift` file with parsing/formatting functions, add `ImportPreviewView.swift` for the import confirmation sheet, then modify `ContentView.swift` to add toolbar buttons and wire up the flows.

---

### Task 1: Create MarkdownParser.swift

**Files:**

- Create: `ios/iOSApp/MarkdownParser.swift`

**Steps:**

1. Create new Swift file with two functions: `parseMarkdown` and `formatMarkdown`
2. `formatMarkdown` converts `[Checklist]` to markdown string
3. `parseMarkdown` converts markdown string to `[Checklist]`

**Code:**

```swift
import Foundation

enum MarkdownParser {
    /// Converts checklists to markdown format
    static func formatMarkdown(_ checklists: [Checklist]) -> String {
        var lines: [String] = []
        for checklist in checklists {
            if !lines.isEmpty {
                lines.append("")
            }
            lines.append("# \(checklist.name)")
            lines.append("")
            for field in checklist.fields {
                lines.append("- \(field.name)")
            }
        }
        return lines.joined(separator: "\n")
    }

    /// Parses markdown into checklists
    /// - Headings (# ) become checklist names
    /// - List items (- ) become fields
    /// - Checkbox syntax (- [ ] or - [x]) is stripped
    /// - Items before first heading go into "Imported Checklist"
    static func parseMarkdown(_ text: String) -> [Checklist] {
        var checklists: [Checklist] = []
        var currentChecklist: Checklist? = nil

        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("# ") {
                // Save previous checklist if exists
                if let current = currentChecklist, !current.fields.isEmpty {
                    checklists.append(current)
                }
                let name = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                currentChecklist = Checklist(name: name.isEmpty ? "Imported Checklist" : name)
            } else if trimmed.hasPrefix("- ") {
                var itemText = String(trimmed.dropFirst(2))

                // Strip checkbox syntax: [ ] or [x]
                if itemText.hasPrefix("[ ] ") {
                    itemText = String(itemText.dropFirst(4))
                } else if itemText.hasPrefix("[x] ") || itemText.hasPrefix("[X] ") {
                    itemText = String(itemText.dropFirst(4))
                }

                itemText = itemText.trimmingCharacters(in: .whitespaces)

                if !itemText.isEmpty {
                    // Create default checklist if none exists
                    if currentChecklist == nil {
                        currentChecklist = Checklist(name: "Imported Checklist")
                    }
                    currentChecklist?.fields.append(Field(name: itemText))
                }
            }
        }

        // Don't forget the last checklist
        if let current = currentChecklist, !current.fields.isEmpty {
            checklists.append(current)
        }

        return checklists
    }
}
```

---

### Task 2: Create ImportPreviewView.swift

**Files:**

- Create: `ios/iOSApp/ImportPreviewView.swift`

**Steps:**

1. Create SwiftUI sheet that displays parsed checklists
2. Show checklist name and item count for each
3. Add Import and Cancel buttons

**Code:**

```swift
import SwiftUI

struct ImportPreviewView: View {
    let checklists: [Checklist]
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
```

---

### Task 3: Add state variables to ContentView

**Files:**

- Modify: `ios/iOSApp/ContentView.swift` (lines 6-7)

**Steps:**

1. Add state for showing import preview sheet
2. Add state for parsed checklists to import
3. Add state for showing alerts

**Code:**

Add after line 7 (`@State private var newListName: String = ""`):

```swift
@State private var showingImportPreview = false
@State private var checklistsToImport: [Checklist] = []
@State private var showingExportConfirmation = false
@State private var showingImportError = false
@State private var importErrorMessage = ""
```

---

### Task 4: Add toolbar buttons for Import/Export

**Files:**

- Modify: `ios/iOSApp/ContentView.swift` (lines 82-87)

**Steps:**

1. Add Import button (leading position)
2. Add Export button (trailing position, before plus button)

**Code:**

Replace the existing toolbar (lines 76-88) with:

```swift
.toolbar {
    ToolbarItem(placement: .principal) {
        Text("My Checklists")
            .font(.system(size: 22, weight: .regular))
            .foregroundColor(.black)
    }
    ToolbarItem(placement: .navigationBarLeading) {
        Button(action: importFromClipboard) {
            Image(systemName: "square.and.arrow.down")
                .foregroundColor(.black)
        }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button(action: exportToClipboard) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.black)
        }
        .disabled(store.lists.isEmpty)

        Button(action: { showingNewListSheet = true }) {
            Image(systemName: "plus")
                .foregroundColor(.black)
        }
    }
}
```

---

### Task 5: Add import/export functions to ContentView

**Files:**

- Modify: `ios/iOSApp/ContentView.swift` (after `createList` function, around line 115)

**Steps:**

1. Add `exportToClipboard` function
2. Add `importFromClipboard` function

**Code:**

Add after the `createList()` function:

```swift
private func exportToClipboard() {
    let markdown = MarkdownParser.formatMarkdown(store.lists)
    UIPasteboard.general.string = markdown
    showingExportConfirmation = true
}

private func importFromClipboard() {
    guard let text = UIPasteboard.general.string, !text.isEmpty else {
        importErrorMessage = "Clipboard is empty"
        showingImportError = true
        return
    }

    let parsed = MarkdownParser.parseMarkdown(text)
    if parsed.isEmpty {
        importErrorMessage = "No checklist items found in clipboard"
        showingImportError = true
        return
    }

    checklistsToImport = parsed
    showingImportPreview = true
}

private func confirmImport() {
    store.lists.append(contentsOf: checklistsToImport)
    checklistsToImport = []
    showingImportPreview = false
}
```

---

### Task 6: Add sheets and alerts to ContentView

**Files:**

- Modify: `ios/iOSApp/ContentView.swift` (after existing `.sheet` modifier, around line 107)

**Steps:**

1. Add import preview sheet
2. Add export confirmation alert
3. Add import error alert

**Code:**

Add after the existing `.sheet(isPresented: $showingNewListSheet)` block (after line 107):

```swift
.sheet(isPresented: $showingImportPreview) {
    ImportPreviewView(
        checklists: checklistsToImport,
        onImport: confirmImport,
        onCancel: {
            checklistsToImport = []
            showingImportPreview = false
        }
    )
}
.alert("Copied to Clipboard", isPresented: $showingExportConfirmation) {
    Button("OK", role: .cancel) {}
} message: {
    Text("Your checklists have been copied as markdown.")
}
.alert("Import Failed", isPresented: $showingImportError) {
    Button("OK", role: .cancel) {}
} message: {
    Text(importErrorMessage)
}
```

---

### Task 7: Test the feature

**Steps:**

1. Build the app: `just build` or run from Xcode
2. Test export: Create a checklist with items, tap export, paste in Notes to verify markdown format
3. Test import: Copy markdown text (e.g., `# Test\n\n- Item 1\n- Item 2`), tap import, verify preview, confirm
4. Test edge cases:
   - Export with no checklists (button should be disabled)
   - Import with empty clipboard (should show error)
   - Import non-markdown text (should show "no items found" error)
   - Import markdown with checkbox syntax (`- [x] item`)

---

## Summary of Changes

| File | Action | Description |
|------|--------|-------------|
| `ios/iOSApp/MarkdownParser.swift` | Create | Parsing and formatting functions |
| `ios/iOSApp/ImportPreviewView.swift` | Create | Import confirmation sheet UI |
| `ios/iOSApp/ContentView.swift` | Modify | Add toolbar buttons, state, sheets, alerts, and functions |
