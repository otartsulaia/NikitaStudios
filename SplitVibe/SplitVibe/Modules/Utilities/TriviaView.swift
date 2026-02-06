import SwiftUI

struct TriviaView: View {
    @State private var viewModel = TriviaViewModel()
    @State private var selectedScale: String?

    private let letterPrefixes = ["A", "B", "C", "D"]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Glass Header
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.cyan)
                    .font(.subheadline.weight(.semibold))

                Text("Trivia")
                    .font(.subheadline.bold())

                Spacer()

                // Score as gradient pill
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("\(viewModel.correctCount)/\(viewModel.totalAnswered)")
                        .font(.caption.bold().monospacedDigit())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 18) {
                        // MARK: - Question Number + Category Row
                        HStack(spacing: 8) {
                            // Question number indicator
                            Text("Q\(viewModel.totalAnswered + (viewModel.hasAnswered ? 0 : 1))")
                                .font(.caption2.bold().monospacedDigit())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.ultraThinMaterial, in: Capsule())

                            // Category tag/chip
                            Text(question.category)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(categoryColor(for: question.category).gradient, in: Capsule())
                        }
                        .padding(.top, 16)

                        // MARK: - Question Text
                        Text(question.text)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)

                        // MARK: - Answer Buttons
                        VStack(spacing: 10) {
                            ForEach(Array(question.shuffledAnswers.enumerated()), id: \.element) { index, answer in
                                answerButton(
                                    answer,
                                    question: question,
                                    letterPrefix: index < letterPrefixes.count ? letterPrefixes[index] : "?"
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Next Question Button
                        if viewModel.hasAnswered {
                            Button {
                                Haptics.tap()
                                withAnimation(.spring(duration: 0.35)) {
                                    viewModel.nextQuestion()
                                    selectedScale = nil
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Next Question")
                                        .font(.subheadline.bold())
                                    Image(systemName: "arrow.right")
                                        .font(.caption.bold())
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                                    in: Capsule()
                                )
                                .shadow(color: .cyan.opacity(0.3), radius: 10, y: 4)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 20)
                }
            } else {
                VStack(spacing: 14) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading questions...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Answer Button

    private func answerButton(_ answer: String, question: TriviaQuestion, letterPrefix: String) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let isCorrect = answer == question.correctAnswer
        let showResult = viewModel.hasAnswered

        return Button {
            guard !viewModel.hasAnswered else { return }
            selectedScale = answer
            withAnimation(.spring(duration: 0.35)) {
                viewModel.answer(answer)
            }
            if answer == question.correctAnswer {
                Haptics.success()
            } else {
                Haptics.error()
            }
        } label: {
            HStack(spacing: 12) {
                // Letter prefix circle
                Text(letterPrefix)
                    .font(.caption.bold())
                    .foregroundStyle(prefixForeground(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
                    .frame(width: 28, height: 28)
                    .background(
                        prefixBackground(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult),
                        in: Circle()
                    )

                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if showResult {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundStyle(isCorrect ? .green : .red)
                        .font(.subheadline)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(backgroundColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult), lineWidth: 1.5)
            )
            // Glow effect for correct/wrong
            .shadow(
                color: glowColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult),
                radius: showResult && (isCorrect || isSelected) ? 8 : 0
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(selectedScale == answer ? 0.97 : 1.0)
        .animation(.spring(duration: 0.25), value: selectedScale)
    }

    // MARK: - Styling Helpers

    private func prefixForeground(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else { return .secondary }
        if isCorrect { return .white }
        if isSelected { return .white }
        return .secondary
    }

    private func prefixBackground(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else { return Color.white.opacity(0.08) }
        if isCorrect { return .green }
        if isSelected { return .red }
        return Color.white.opacity(0.08)
    }

    private func backgroundColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else { return .clear }
        if isCorrect { return .green.opacity(0.1) }
        if isSelected { return .red.opacity(0.1) }
        return .clear
    }

    private func borderColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else {
            return isSelected ? .cyan.opacity(0.6) : Color.white.opacity(0.06)
        }
        if isCorrect { return .green.opacity(0.6) }
        if isSelected { return .red.opacity(0.6) }
        return Color.white.opacity(0.06)
    }

    private func glowColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else { return .clear }
        if isCorrect { return .green.opacity(0.3) }
        if isSelected { return .red.opacity(0.3) }
        return .clear
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "science": return .blue
        case "history": return .brown
        case "geography": return .green
        case "music": return .pink
        case "technology": return .indigo
        case "nature": return .mint
        case "sports": return .orange
        case "movies": return .purple
        case "food": return .red
        default: return .gray
        }
    }
}

// MARK: - View Model

@Observable
final class TriviaViewModel {
    var currentQuestion: TriviaQuestion?
    var selectedAnswer: String?
    var hasAnswered = false
    var correctCount = 0
    var totalAnswered = 0

    private var questions: [TriviaQuestion] = []
    private var currentIndex = 0

    init() {
        loadQuestions()
    }

    func answer(_ answer: String) {
        selectedAnswer = answer
        hasAnswered = true
        totalAnswered += 1
        if answer == currentQuestion?.correctAnswer {
            correctCount += 1
        }
    }

    func nextQuestion() {
        currentIndex += 1
        if currentIndex >= questions.count {
            currentIndex = 0
            questions.shuffle()
        }
        currentQuestion = questions[currentIndex]
        selectedAnswer = nil
        hasAnswered = false
    }

    private func loadQuestions() {
        questions = TriviaQuestion.sampleQuestions.shuffled()
        currentQuestion = questions.first
    }
}

// MARK: - Model

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let category: String
    let text: String
    let correctAnswer: String
    let wrongAnswers: [String]

    var shuffledAnswers: [String] {
        (wrongAnswers + [correctAnswer]).shuffled()
    }

    static let sampleQuestions: [TriviaQuestion] = [
        TriviaQuestion(category: "Science", text: "What planet is known as the Red Planet?", correctAnswer: "Mars", wrongAnswers: ["Venus", "Jupiter", "Saturn"]),
        TriviaQuestion(category: "History", text: "In what year did World War II end?", correctAnswer: "1945", wrongAnswers: ["1944", "1946", "1943"]),
        TriviaQuestion(category: "Geography", text: "What is the largest ocean on Earth?", correctAnswer: "Pacific Ocean", wrongAnswers: ["Atlantic Ocean", "Indian Ocean", "Arctic Ocean"]),
        TriviaQuestion(category: "Music", text: "Which band performed 'Bohemian Rhapsody'?", correctAnswer: "Queen", wrongAnswers: ["The Beatles", "Led Zeppelin", "Pink Floyd"]),
        TriviaQuestion(category: "Science", text: "What is the chemical symbol for gold?", correctAnswer: "Au", wrongAnswers: ["Ag", "Fe", "Go"]),
        TriviaQuestion(category: "Technology", text: "Who co-founded Apple Inc.?", correctAnswer: "Steve Jobs", wrongAnswers: ["Bill Gates", "Mark Zuckerberg", "Jeff Bezos"]),
        TriviaQuestion(category: "Nature", text: "What is the fastest land animal?", correctAnswer: "Cheetah", wrongAnswers: ["Lion", "Horse", "Gazelle"]),
        TriviaQuestion(category: "Sports", text: "How many players are on a soccer team?", correctAnswer: "11", wrongAnswers: ["9", "10", "12"]),
        TriviaQuestion(category: "Movies", text: "Who directed 'Inception'?", correctAnswer: "Christopher Nolan", wrongAnswers: ["Steven Spielberg", "James Cameron", "Ridley Scott"]),
        TriviaQuestion(category: "Food", text: "What fruit is known as the 'King of Fruits'?", correctAnswer: "Durian", wrongAnswers: ["Mango", "Pineapple", "Jackfruit"]),
        TriviaQuestion(category: "Science", text: "What gas do plants absorb from the atmosphere?", correctAnswer: "Carbon dioxide", wrongAnswers: ["Oxygen", "Nitrogen", "Hydrogen"]),
        TriviaQuestion(category: "Geography", text: "What is the smallest country in the world?", correctAnswer: "Vatican City", wrongAnswers: ["Monaco", "San Marino", "Liechtenstein"]),
        TriviaQuestion(category: "History", text: "Who was the first person to walk on the Moon?", correctAnswer: "Neil Armstrong", wrongAnswers: ["Buzz Aldrin", "Yuri Gagarin", "John Glenn"]),
        TriviaQuestion(category: "Music", text: "What instrument has 88 keys?", correctAnswer: "Piano", wrongAnswers: ["Guitar", "Violin", "Organ"]),
        TriviaQuestion(category: "Technology", text: "What does 'HTTP' stand for?", correctAnswer: "HyperText Transfer Protocol", wrongAnswers: ["High Tech Transfer Protocol", "HyperText Transmission Program", "Home Tool Transfer Protocol"]),
    ]
}
