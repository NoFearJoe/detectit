import UIKit
import DetectItCore

extension QuestTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData(task: state.task) { [weak self] success in
            guard let self = self else { return }
            
            self.state.isDataLoaded = success
            
            self.updateContentState(animated: false)
            
            self.screenLoadingView.setVisible(false, animated: true)
            self.screenPlaceholderView.setVisible(!success, animated: false)
            
            if !success {
                Analytics.logScreenError(screen: .questTask)
            }
        }
    }
    
    func loadData(
        task: QuestTask,
        completion: @escaping (Bool) -> Void
    ) {
        loadAnswer()
        completion(true)
    }
    
    func loadAnswer() {
        state.answer = TaskAnswer.get(questTaskID: state.task.id)
    }
    
    func saveScoreAndAnswer(score: Int, answer: TaskAnswer.QuestTaskAnswer) {
        TaskScore.set(value: score, id: state.task.id, taskKind: state.task.kind)
        TaskAnswer.set(answer: answer, questTaskID: state.task.id)
    }
    
}
