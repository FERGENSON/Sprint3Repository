
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
   
    
    
    // MARK: - Properties
    
    let questionsAmount: Int = 10
    
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    var correctAnswers: Int = 0
    
    var questionFactory: QuestionFactoryProtocol?
    
    var alertPresenter: AlertPresenterProtocol?
    
    private var statisticsService = StatisticsService()
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
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
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
                self?.viewController?.imageView.layer.borderWidth = 0
            }
        }
    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        guard let question = question else {
//            return
//        }
//        
//        currentQuestion = question
//        let viewModel = convert(model: question)
//        DispatchQueue.main.async { [weak self] in
//            self?.viewController?.show(quiz: viewModel)
//        }
//    }
        
        func showNextQuestionOrResults() {
            if isLastQuestion() {
                
                statisticsService.store(correct: correctAnswers, total: self.questionsAmount)
                
                let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount) \n Количество сыграных квизов: \(statisticsService.gamesCount) \n Рекорд: \(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total) (\(statisticsService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy)) %"
                
                let viewModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть ещё раз", completion: {[weak self] in
                        
                        guard let self = self else { return }
                        
                        restartGame()
                        self.correctAnswers = 0
                        
                        questionFactory?.requestNextQuestion()
                    })
                alertPresenter?.presentAlert(result: viewModel)
            } else {
                switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
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


