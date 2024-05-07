import UIKit
import RxSwift
import RxCocoa

class TodoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckbox: CheckUIButton!
    
    // Constants for cell reuse and nib name
    static let nibName = "TodoTableViewCell"
    static let identifier = "TodoCell"
    
    // ViewModel for the cell
    var viewModel = TodoViewModel(Todo.empty)
    
    // Dispose bag for managing disposables
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Bind data to the cell
    func bind(task: Todo) {
        viewModel = TodoViewModel(task)
        
        // Set up UI bindings
        setupBindings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear dispose bag when cell is reused
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI Binding
    
    // Set up bindings for UI elements
    func setupBindings() {
        let task = viewModel.task.asDriver()
        
        // Title
        task.map { $0.title }
            .drive(lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        // Description
        task.map { $0.description ?? "" }
            .drive(lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        // Hide description label if description is empty
        task.map {
                if $0.description?.isEmpty == false { return false }
                return true
            }
            .drive(lblDescription.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Time
        task.map { $0.time ?? "" }
            .drive(lblTime.rx.text)
            .disposed(by: disposeBag)
        
        // Hide time label if time is empty
        task.map {
                if $0.time?.isEmpty == false { return false }
                return true
            }
            .drive(lblTime.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Bind checkbox image
        viewModel.checkImageString.asDriver(onErrorJustReturn: "circle")
            .map { UIImage(systemName: $0) }
            .drive(btnCheckbox.rx.backgroundImage())
            .disposed(by: disposeBag)
    }
}

// Custom UIButton subclass to hold an index path
class CheckUIButton : UIButton {
    var indexPath: IndexPath?
}

