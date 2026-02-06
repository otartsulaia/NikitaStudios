import SwiftUI

struct PomodoroTimerView: View {
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var isBreak = false
    @State private var sessionsCompleted = 0

    private let workDuration = 25 * 60
    private let breakDuration = 5 * 60

    var body: some View {
        VStack(spacing: 16) {
            // Status
            HStack {
                Image(systemName: isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                    .foregroundStyle(isBreak ? .green : .indigo)
                    .font(.caption)
                Text(isBreak ? "Break Time" : "Focus Time")
                    .font(.subheadline.bold())
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < sessionsCompleted ? Color.indigo : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Spacer()

            // Timer display
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isBreak ? Color.green : Color.indigo,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)

                    Text(isBreak ? "Relax" : "Stay focused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Controls
            HStack(spacing: 24) {
                Button {
                    reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }

                Button {
                    toggleTimer()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(isBreak ? .green : .indigo, in: Circle())
                }

                Button {
                    skip()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemBackground), in: Circle())
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }

    private var progress: CGFloat {
        let total = CGFloat(isBreak ? breakDuration : workDuration)
        return CGFloat(total - CGFloat(timeRemaining)) / total
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timerCompleted()
                }
            }
        }
        isRunning.toggle()
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        if !isBreak {
            sessionsCompleted += 1
        }
        isBreak.toggle()
        timeRemaining = isBreak ? breakDuration : workDuration
    }

    private func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = isBreak ? breakDuration : workDuration
    }

    private func skip() {
        timerCompleted()
    }
}
