import SwiftUI

enum AnimationConstants {
    static let panelSpring = Animation.spring(response: 0.38, dampingFraction: 0.80)
    static let fadeIn      = Animation.easeOut(duration: 0.2)
    static let fadeOut     = Animation.easeIn(duration: 0.15)
}
