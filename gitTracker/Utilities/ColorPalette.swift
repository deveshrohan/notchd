import SwiftUI

enum ColorPalette {
    static let contributionColors: [Color] = [
        Color(red: 0.086, green: 0.106, blue: 0.133), // level 0 — empty
        Color(red: 0.055, green: 0.267, blue: 0.161), // level 1
        Color(red: 0.000, green: 0.427, blue: 0.196), // level 2
        Color(red: 0.149, green: 0.651, blue: 0.255), // level 3
        Color(red: 0.224, green: 0.827, blue: 0.325), // level 4
    ]

    static let background = Color(red: 0.067, green: 0.075, blue: 0.094)
    static let surface    = Color(red: 0.098, green: 0.110, blue: 0.133)
    static let border     = Color(red: 0.173, green: 0.196, blue: 0.231)
    static let textPrimary   = Color(red: 0.929, green: 0.933, blue: 0.941)
    static let textSecondary = Color(red: 0.498, green: 0.557, blue: 0.639)
}
