import UIKit
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController {
    
    // MARK: - IBoutlets
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    private var tasks = BehaviorRelay<[Task]>(value: []) //RxCocoa
    private var filteredTask = [Task]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - IBAction
    @IBAction func priorityValueChange(_ sender: UISegmentedControl) {
        let priority = Priority(rawValue: self.prioritySegmentControl.selectedSegmentIndex - 1)
        
        filterTaskForPriority(by: priority)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? UINavigationController,
              let addTaskVC = destination.viewControllers.first as? AddTaskViewController else { return }
        
        addTaskVC.subjectObservable
            .subscribe(onNext: { [unowned self] task in
                
                let priority = Priority(rawValue: self.prioritySegmentControl.selectedSegmentIndex - 1)
                
                // RxCocoa => BehaviorRelay
                var existingTask = self.tasks.value
                existingTask.append(task)
                self.tasks.accept(existingTask)
                
                self.filterTaskForPriority(by: priority)
                
            }).disposed(by: disposeBag)
        
    }

}

// MARK: - Private Methods
private extension TaskListViewController {
    
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    func filterTaskForPriority(by priority: Priority?) {
        
        if priority == nil {
            filteredTask = tasks.value
            updateTableView()
        } else {
            
            tasks.map { task in
                return task.filter { $0.priority == priority! }
            }.subscribe(onNext: { tasks in
                self.filteredTask = tasks
                self.updateTableView()
            }).disposed(by: disposeBag)
        }
        
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Extensions
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTask.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)
        
        cell.textLabel?.text = filteredTask[indexPath.row].title
        
        return cell
        
    }
}
