import Foundation
import RxSwift
import RxCocoa

class TodoViewModel: NSObject {
    // Behavior relay to hold the task
    var task = BehaviorRelay<Todo>(value: Todo.empty)
    
    // Dispose bag for managing disposables
    var disposeBag = DisposeBag()
    
    // Initialize with a task
    init(_ task: Todo) {
        // Subscribe to the task and accept its value
        _ = BehaviorSubject<Todo>.just(task)
            .take(1)
            .subscribe(onNext: self.task.accept(_:))
            .disposed(by: disposeBag)
    }
    
    // Observable to track the checkmark image string based on task completion status
    lazy var checkImageString: Observable<String> = self.task.map { return $0.isCompleted ? "checkmark.circle.fill" : "circle" }
}
