import UIKit
import RxSwift

class AddTaskViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    // MARK: - Vars
    private let subject = PublishSubject<Task>()
    var subjectObservable: Observable<Task> {
        return subject.asObservable()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    // MARK: - IBActions
    @IBAction func saveTask(_ sender: Any) {
        
        guard let priority = Priority(rawValue: prioritySegmentControl.selectedSegmentIndex), let title = taskTitleTextField.text else {
            return
        }
        
        let task = Task(title: title, priority: priority)
        subject.onNext(task)
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Private Methods
private extension AddTaskViewController {
    
    func setupUI() {
        //
    }
}

