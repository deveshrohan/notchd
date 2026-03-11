import SwiftUI
import Lottie

struct AnimatedFlameView: View {
    let streak: Int

    private var animationSpeed: CGFloat {
        switch streak {
        case 0:         return 0
        case 1..<4:     return 0.4
        case 4..<7:     return 0.7
        case 7..<11:    return 1.0
        case 11..<16:   return 1.4
        case 16..<31:   return 1.9
        default:        return 2.6
        }
    }

    private var frameSize: CGFloat {
        switch streak {
        case 0:         return 20
        case 1..<4:     return 22
        case 4..<7:     return 26
        case 7..<11:    return 30
        case 11..<16:   return 35
        case 16..<31:   return 40
        default:        return 48
        }
    }

    var body: some View {
        if streak == 0 {
            Text("🔥")
                .font(.system(size: 14))
        } else {
            LottieView(animation: .named("flame"))
                .playing(loopMode: .loop)
                .animationSpeed(animationSpeed)
                .frame(width: frameSize, height: frameSize)
        }
    }
}
