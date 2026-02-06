import SwiftUI

struct PomodoroTimerView: View {
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var isBreak = false
    @State private var sessionsCompleted = 0

    private let workDuration = 25 * 60
    private let breakDuration = 5 * 60

    private var workGradient: [Color] { [.indigo, .purple] }
    private var breakGradient: [Color] { [.green, .mint] }
    private var activeGradient: [Color] { isBreak ? breakGradient : workGradient }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Glass Header Bar
            HStack {
                Image(systemName: isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                    .foregroundStyle(
                        LinearGradient(colors: activeGradient, startPoint: .leading, endPoint: .trailing)
                    )
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.symbolEffect(.replace))

                Text(isBreak ? "Break Time" : "Focus Time")
                    .font(.subheadline.bold())
                    .contentTransition(.numericText())

                Spacer()

                // Session dots as capsules
                HStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { i in
                        Capsule()
                            .fill(
                                i < sessionsCompleted
                                    ? LinearGradient(colors: workGradient, startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: 18, height: 7)
                            .animation(.spring(duration: 0.4), value: sessionsCompleted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Spacer()

            // MARK: - Timer Circle
            ZStack {
                // Glow shadow behind progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: activeGradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 12)
                    .opacity(0.5)

                // Background track
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 12)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: activeGradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time display
                VStack(spacing: 6) {
                    Text(timeString)
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.1), value: timeRemaining)

                    Text(isBreak ? "Relax" : "Stay focused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // MARK: - Control Buttons
            HStack(spacing: 28) {
                // Reset - glass circle
                Button {
                    Haptics.tap()
                    reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }

                // Play/Pause - large gradient circle with shadow
                Button {
                    Haptics.tap()
                    toggleTimer()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(colors: activeGradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle()
                        )
                        .shadow(color: activeGradient.first?.opacity(0.5) ?? .clear, radius: 12, y: 4)
                        .contentTransition(.symbolEffect(.replace))
                }

                // Skip - glass circle
                Button {
                    Haptics.tap()
                    skip()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Computed Properties

    private var progress: CGFloat {
        let total = CGFloat(isBreak ? breakDuration : workDuration)
        return CGFloat(total - CGFloat(timeRemaining)) / total
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Timer Logic

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
        Haptics.success()

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
