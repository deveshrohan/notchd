import SwiftUI

struct ContributionGridView: View {
    let weeks: [ContributionWeek]

    private let cellSize:    CGFloat = 10
    private let cellSpacing: CGFloat = 3

    // Per-cell state driven by tasks below
    @State private var visibleCells:  Set<String> = []   // entrance: cells that have popped in
    @State private var blinkingCells: Set<String> = []   // ongoing: cells currently glowing

    @State private var entranceTask: Task<Void, Never>?
    @State private var blinkTask:    Task<Void, Never>?

    private var allDates: [String] {
        weeks.flatMap { $0.contributionDays.map(\.date) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            monthLabels
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    ForEach(weeks) { week in
                        VStack(spacing: cellSpacing) {
                            ForEach(week.contributionDays) { day in
                                ContributionCellView(
                                    day: day,
                                    size: cellSize,
                                    isVisible:  visibleCells.contains(day.date),
                                    isBlinking: blinkingCells.contains(day.date)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            legend
                .opacity(visibleCells.count == allDates.count ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: visibleCells.count)
        }
        .onAppear { startEntrance() }
        .onDisappear { cancelTasks() }
    }

    // MARK: - Entrance: cells pop in at random positions

    private func startEntrance() {
        let shuffled = allDates.shuffled()
        entranceTask = Task { @MainActor in
            var remaining = shuffled
            while !remaining.isEmpty {
                guard !Task.isCancelled else { return }
                let batchSize = Int.random(in: 3...6)
                let batch = Array(remaining.prefix(batchSize))
                remaining = Array(remaining.dropFirst(batchSize))
                withAnimation { visibleCells.formUnion(batch) }
                try? await Task.sleep(for: .milliseconds(28))
            }
            // All cells revealed — start brief blink, stop after 1 second
            if !Task.isCancelled {
                startBlink()
                try? await Task.sleep(for: .seconds(1))
                blinkTask?.cancel()
            }
        }
    }

    // MARK: - Ongoing: random cells flash brighter

    private func startBlink() {
        let dates = allDates
        guard !dates.isEmpty else { return }
        blinkTask = Task { @MainActor in
            while !Task.isCancelled {
                // Random idle gap between blink events
                try? await Task.sleep(for: .milliseconds(Int.random(in: 55...110)))
                guard !Task.isCancelled else { return }

                let count = Int.random(in: 1...3)
                let toLight = Set((0..<count).compactMap { _ in dates.randomElement() })

                withAnimation { blinkingCells.formUnion(toLight) }

                // Hold the glow for a short random duration
                try? await Task.sleep(for: .milliseconds(Int.random(in: 100...200)))
                guard !Task.isCancelled else { return }

                withAnimation { blinkingCells.subtract(toLight) }
            }
        }
    }

    private func cancelTasks() {
        entranceTask?.cancel(); entranceTask = nil
        blinkTask?.cancel();    blinkTask    = nil
        visibleCells  = []
        blinkingCells = []
    }

    // MARK: - Month labels

    private var monthLabels: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(monthPositions, id: \.name) { pos in
                Text(pos.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(ColorPalette.textSecondary)
                    .frame(width: pos.width, alignment: .leading)
            }
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.system(size: 9))
                .foregroundStyle(ColorPalette.textSecondary)
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorPalette.contributionColors[i])
                    .frame(width: cellSize, height: cellSize)
            }
            Text("More")
                .font(.system(size: 9))
                .foregroundStyle(ColorPalette.textSecondary)
        }
        .padding(.leading, 2)
    }

    // MARK: - Month positions

    private struct MonthPosition { let name: String; let width: CGFloat }

    private var monthPositions: [MonthPosition] {
        guard !weeks.isEmpty else { return [] }
        let step = cellSize + cellSpacing
        var out: [MonthPosition] = []
        var curMonth = ""; var startWeek = 0
        for (i, week) in weeks.enumerated() {
            if let first = week.contributionDays.first {
                let m = monthAbbrev(from: first.date)
                if m != curMonth {
                    if !curMonth.isEmpty {
                        out.append(MonthPosition(name: curMonth, width: CGFloat(i - startWeek) * step))
                    }
                    curMonth = m; startWeek = i
                }
            }
        }
        if !curMonth.isEmpty {
            out.append(MonthPosition(name: curMonth, width: CGFloat(weeks.count - startWeek) * step))
        }
        return out
    }

    private func monthAbbrev(from dateString: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        guard let date = df.date(from: dateString) else { return "" }
        df.dateFormat = "MMM"
        return df.string(from: date)
    }
}
