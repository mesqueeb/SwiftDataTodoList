import SwiftData
import SwiftUI

public struct SwiftDataQuery<T: PersistentModel, Content: View>: View {
  /// Inspired by the @Query macro
  var swiftDataQuery: SwiftData.Query<[T].Element, [T]>
  var items: [T] { swiftDataQuery.wrappedValue }
  let content: (T) -> Content

  public init(
    predicate: Predicate<T>? = nil,
    sortBy: [SortDescriptor<T>] = [],
    fetchLimit: Int? = nil,
    @ViewBuilder content: @escaping (T) -> Content // Slot Content
  ) {
    var descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
    if let fetchLimit { descriptor.fetchLimit = fetchLimit }

    self.swiftDataQuery = .init(descriptor)
    self.content = content
  }

  public var body: some View {
    ForEach(items, id: \.id) { item in
      self.content(item)
        .id(item.id) // Use ID for List reordering and animations
    }
  }
}
