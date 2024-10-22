
import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Properties
    
    let questionsAmount: Int = 10
    
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Actions
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func noButtonClicked() {
          guard let currentQuestion = currentQuestion else {
              return
          }
          
          let givenAnswer = false
          
          viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
      }
    
    // MARK: - Functions
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
    
    func resetQuestionIndex() {
            currentQuestionIndex = 0
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
