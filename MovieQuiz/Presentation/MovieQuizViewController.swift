
import UIKit

final class MovieQuizViewController: UIViewController
{
    // MARK: - IB Outlets
    
    @IBOutlet weak internal var imageView: UIImageView!
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private properties
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var statisticsService = StatisticsService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
//        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        
        statisticsService = StatisticsService()
        
//        showLoadingIndicator()
//        presenter.questionFactory?.loadData()
        
        self.alertPresenter = AlertPresenter()
        self.alertPresenter?.delegate = self
        
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrect: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = presenter.correctAnswers
            self.presenter.showNextQuestionOrResults()
        }
        
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            
//            statisticsService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
//            
//            let text = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount) \n Количество сыграных квизов: \(statisticsService.gamesCount) \n Рекорд: \(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total) (\(statisticsService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy)) %"
//            
//            let viewModel = AlertModel(
//                title: "Этот раунд окончен!",
//                message: text,
//                buttonText: "Сыграть ещё раз", completion: {[weak self] in
//                    
//                    guard let self = self else { return }
//                    
//                    self.presenter.restartGame()
//                    
//                    presenter.questionFactory?.requestNextQuestion()
//                })
//            alertPresenter?.presentAlert(result: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//            presenter.questionFactory?.requestNextQuestion()
//        }
//    }
    
    func showLoadingIndicator () {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator () {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError (message:String) {
        hideLoadingIndicator ()
        
        let text = "Произошла ошибка"
        let viewModel = AlertModel(title: text,
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            
        }
        alertPresenter?.presentAlert(result: viewModel)
    }
    
}
