import SwiftUI

struct ContributionCellView: View {
    let day: ContributionDay
    let size: CGFloat
    var isVisible: Bool = true
    var isBlinking: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(ColorPalette.contributionColors[day.contributionLevel.colorIndex])
            .frame(width: size, height: size)
            .brightness(isBlinking ? 0.35 : 0)
            .scaleEffect(isBlinking ? 1.14 : (isVisible ? 1.0 : 0.4))
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.08), value: isVisible)
            .animation(.easeInOut(duration: 0.11), value: isBlinking)
            .help("\(day.contributionCount) contribution\(day.contributionCount == 1 ? "" : "s") on \(formattedDate)")
    }

    private var formattedDate: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        guard let date = df.date(from: day.date) else { return day.date }
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
}
