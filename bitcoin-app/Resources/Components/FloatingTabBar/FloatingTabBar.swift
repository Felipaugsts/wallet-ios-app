import SwiftUI

struct TabBarConfiguration: Codable {
    let items: [TabItem]
}

struct TabItem: Codable, Identifiable {
    let id: String
    let icon: String
    let visible: Bool
}

extension TabItem {
    static var loadingStateTabs: [TabItem] {
        [
            .init(id: "loadingStateTab1", icon: "loading", visible: true),
            .init(id: "loadingStateTab2", icon: "loading", visible: true),
        ]
    }
}
struct FloatingTabBar: View {
    
    @Binding var selectedId: String
    var items: [TabItem]
    
    @Namespace private var animation
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(items) { item in
                    if item.visible {
                        Button {
                            selectedId = item.id
                        } label: {
                            ZStack {
                                if selectedId == item.id {
                                    Circle()
                                        .fill(ColorPalette.purple.opacity(UserDefaultsUtils.shared.getDarkMode() ? 1 : 0.7))
                                        .matchedGeometryEffect(
                                            id: "activeTab",
                                            in: animation
                                        )
                                        .frame(width: 55, height: 55)
                                }
                                
                                Image(systemName: item.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(
                                        selectedId == item.id ? .white : .gray
                                    )
                            }
                            .frame(maxWidth: 75)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(ColorPalette.black.opacity(0.8))
                    .shadow(color: ColorPalette.light.opacity(0.3), radius: 5, x: 0, y: 3)
            )
            .padding(.horizontal)
        }
    }
}
