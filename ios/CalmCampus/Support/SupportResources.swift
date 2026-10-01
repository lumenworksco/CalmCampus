import SwiftUI

/// People to talk to. Ported from the Flutter app (tag `flutter-final`) plus
/// Belgium's suicide-prevention line. VERIFY contact details before any release.
struct SupportResource: Identifiable {
    let id: String
    let name: String
    let detail: String
    let actionLabel: String
    let url: URL
    let isUrgent: Bool
}

enum SupportResources {
    static let all: [SupportResource] = [
        SupportResource(id: "tele-onthaal", name: "Tele-Onthaal",
                        detail: "Anonymous, 24/7, for anyone who needs to talk.",
                        actionLabel: "Call 106", url: URL(string: "tel:106")!, isUrgent: true),
        SupportResource(id: "zelfmoordlijn", name: "Zelfmoordlijn",
                        detail: "24/7 support if you're having thoughts of suicide.",
                        actionLabel: "Call 1813", url: URL(string: "tel:1813")!, isUrgent: true),
        SupportResource(id: "psychologist", name: "Student psychologists, KU Leuven",
                        detail: "Free, confidential support for KU Leuven students.",
                        actionLabel: "Open website",
                        url: URL(string: "https://www.kuleuven.be/studentenvoorzieningen/psychologische-begeleiding")!,
                        isUrgent: false),
        SupportResource(id: "hak", name: "HAK (Huisarts aan de KU)",
                        detail: "On-campus GP for students.",
                        actionLabel: "Call 016 33 20 60", url: URL(string: "tel:+3216332060")!, isUrgent: false),
    ]
}

struct SupportList: View {
    var body: some View {
        ForEach(SupportResources.all) { resource in
            VStack(alignment: .leading, spacing: 6) {
                Text(resource.name).font(.headline)
                Text(resource.detail).font(.subheadline).foregroundStyle(.secondary)
                Link(resource.actionLabel, destination: resource.url)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.vertical, 4)
        }
        Text("In an emergency, call 112.")
            .font(.footnote).foregroundStyle(.secondary)
    }
}

struct SupportView: View {
    var body: some View {
        List { SupportList() }
            .navigationTitle("Talk to someone")
    }
}
