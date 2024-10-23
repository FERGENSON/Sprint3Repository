
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    // MARK: - Properties
    
    let questionsAmount: Int = 10
    
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewControllerProtocol?
    
    var correctAnswers: Int = 0
    
    var questionFactory: QuestionFactoryProtocol?
    
    var alertPresenter: AlertPresenterProtocol?
    
    private let statisticsService: StatisticsServiceProtocol!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticsService = StatisticsService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    
    // MARK: - Functions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.deleteImageBorder()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
            if self.isLastQuestion() {
                
                let text = correctAnswers == self.questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }
    
//    func proceedToNextQuestionOrResults() {
//        if self.isLastQuestion() {
//            
//            let text = makeResultsMessage()
//            
//            let viewModel = AlertModel(
//                title: "Этот раунд окончен!",
//                message: text,
//                buttonText: "Сыграть ещё раз", completion: {[weak self] in
//                    
//                    guard let self = self else { return }
//                    
//                    restartGame()
//                    self.correctAnswers = 0
//                    
//                    questionFactory?.requestNextQuestion()
//                })
//            alertPresenter?.presentAlert(result: viewModel)
//        } else {
//            switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
//        }
//    }
    
    func makeResultsMessage() -> String {
        statisticsService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticsService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticsService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}


