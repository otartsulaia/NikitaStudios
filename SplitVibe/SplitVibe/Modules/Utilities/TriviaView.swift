import SwiftUI

struct TriviaView: View {
    @State private var viewModel = TriviaViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.cyan)
                    .font(.caption)
                Text("Trivia")
                    .font(.subheadline.bold())
                Spacer()
                Text("Score: \(viewModel.correctCount)/\(viewModel.totalAnswered)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 16) {
                        // Category
                        Text(question.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)

                        // Question
                        Text(question.text)
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        // Answers
                        VStack(spacing: 8) {
                            ForEach(question.shuffledAnswers, id: \.self) { answer in
                                answerButton(answer, question: question)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Next button (after answering)
                        if viewModel.hasAnswered {
                            Button {
                                viewModel.nextQuestion()
                            } label: {
                                Text("Next Question")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(.cyan, in: Capsule())
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 16)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading questions...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
    }

    private func answerButton(_ answer: String, question: TriviaQuestion) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let isCorrect = answer == question.correctAnswer
        let showResult = viewModel.hasAnswered

        return Button {
            guard !viewModel.hasAnswered else { return }
            viewModel.answer(answer)
        } label: {
            HStack {
                Text(answer)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showResult {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundStyle(isCorrect ? .green : .red)
                        .font(.caption)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func backgroundColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else {
            return Color(.secondarySystemBackground)
        }
        if isCorrect { return .green.opacity(0.15) }
        if isSelected { return .red.opacity(0.15) }
        return Color(.secondarySystemBackground)
    }

    private func borderColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        guard showResult else {
            return isSelected ? .cyan : .clear
        }
        if isCorrect { return .green }
        if isSelected { return .red }
        return .clear
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
