import SwiftUI
import UIKit

// Simple theme and helpers for styling
enum AppTheme {
    // Background gradient: bottom -> top
    static let backgroundBottom = Color(hex: 0xD7ECE2)
    static let backgroundTop = Color(hex: 0xD3EDDB)
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [backgroundBottom, backgroundTop]),
        startPoint: .bottom,
        endPoint: .top,
    )
    static let tileBackground = Color.white
    static let tileText = Color.black
    static let navItemColor = Color.black
    static var navItemUIColor: UIColor { UIColor(navItemColor) }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

struct TileModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.tileBackground)
            .foregroundColor(AppTheme.tileText)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func tileStyle() -> some View { modifier(TileModifier()) }
}

extension View {
    @ViewBuilder
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

extension View {
    @ViewBuilder
    func tintIfAvailable(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            self
        }
    }
}

// Toggle styled as a white tile with black text
struct TileToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack(spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(AppTheme.tileText.opacity(configuration.isOn ? 1 : 0.35))
                    .imageScale(.large)

                configuration.label
                    .foregroundColor(AppTheme.tileText)
                    .font(.body)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .tileStyle()
    }
}

extension View {
    @ViewBuilder
    func listRowSeparatorHiddenCompat() -> some View {
        if #available(iOS 15.0, *) {
            self.listRowSeparator(.hidden)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func listRowSpacingCompat(_ value: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.listRowSpacing(value)
        } else {
            self
        }
    }
}
