import Foundation

struct ChipCollectionItem: Identifiable, Hashable {
    let id: String
    var title: String
    var subtitle: String?
    var systemImageName: String?

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        systemImageName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImageName = systemImageName
    }
}
