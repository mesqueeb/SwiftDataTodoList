import SwiftData
import SwiftUI

struct TodoListItem: View {
  let item: TodoItem

  @Environment(\.openWindow) private var openWindow
  @State private var isEditing: Bool = false

  private var editingSummary: Binding<String> {
    Binding<String>(
      get: { item.summary },
      set: { newValue in
        Task { try await dbTodo.update(id: item.id, \.summary, newValue) }
      }
    )
  }

  private func toggleChecked(_ item: TodoItem) {
    withAnimation {
      let newValue = !item.isChecked
      Task {
        try await dbTodo.update(id: item.id) { data in
          data.isChecked = newValue
          data.dateChecked = newValue ? Date() : nil
        }
      }
    }
  }

  private func deleteItem(_ item: TodoItem) {
    withAnimation {
      Task { try await dbTodo.delete(id: item.id) }
    }
  }

  private func finishEditing() {
    Task {
      try await dbTodo.update(id: item.id, \.dateUpdated, Date())
      isEditing = false
    }
  }

  var body: some View {
    HStack {
      Button(action: { toggleChecked(item) }) {
        Image(systemName: item.isChecked ? "checkmark.square" : "square")
      }

      if isEditing {
        CInput(modelValue: editingSummary, placeholder: "...", revertOnExit: true, autoFocus: true, onBlur: finishEditing)
          .onSubmit(finishEditing)
          .padding(CGFloat(4))
          .frame(maxWidth: .infinity, alignment: .leading) // Make text take up as much space as possible
      } else {
        Text(item.summary)
          .strikethrough(item.isChecked, color: .gray)
          .padding(CGFloat(4))
          .frame(maxWidth: .infinity, alignment: .leading) // Make text take up as much space as possible
          .contentShape(Rectangle())
          .gesture(
            TapGesture(count: 2).onEnded {
              openWindow(id: "item", value: item.uid)
            }.exclusively(before: TapGesture(count: 1).onEnded {
              isEditing = true
            })
          )

        Button(action: { isEditing = true }) {
          Image(systemName: "pencil")
        }
      }
      Button(action: { deleteItem(item) }) {
        Image(systemName: "trash")
      }
    }
  }
}

#Preview {
  TodoListItem(item: TodoItem(summary: "Hello it's me"))
    .modelContainer(for: TodoItem.self, inMemory: true)
}
