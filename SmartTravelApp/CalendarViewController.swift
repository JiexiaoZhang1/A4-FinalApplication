import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Properties
    
    static let storyboardID = "calendarTask"

    var todoScheduled: [String : [Todo]] = [:] // Dictionary to store todos scheduled by date
    var selectedDate = Date() // Currently selected date in the calendar
    var timer: Timer? // Timer for periodically checking for todos
    
    // MARK: - View Lifecycle
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register observer to listen for data change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshHome(notification:)), name: NSNotification.Name(rawValue: "refreshHome"), object: nil)

        // Load data and reload table view
        loadData()
        tblTasks.reloadData()

        // Register custom table view cell
        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTasks.rowHeight = UITableView.automaticDimension
        
        // Select the currently selected date in the calendar
        calendar.select(selectedDate)
        
        // Set calendar height constraint to half of the view height
        calendarHeightConstraint.constant = self.view.bounds.height / 2
        
        // Customize weekday labels' text color
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = calendar.calendarWeekdayView.weekdayLabels[0].textColor
        
        // Set calendar scope to week view
        calendar.scope = .week
        
        // Start the timer for periodic checking of todos
        startTimer()
        
        // Show notification (commented out)
        /*
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("nana")
            self.appDelegate?.scheduleNotification(notificationType: "hello word")
        }
        */
    }
   
    // MARK: - Timer
    
    @objc func checkTime() {
        // Perform time-based checks here
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForTodos), userInfo: nil, repeats: true)
    }

    @objc func checkForTodos() {
        // Perform your checks for todos here
        // Check if there are any todos...
        // If there are, print the data and perform other actions
        // print("Checking for todos...")
        loadData() // Call your loadData() method
    }

    func stopTimer() {
        timer?.invalidate()
    }
    
    // MARK: - Data Loading and Notifications
    
    @objc func refreshHome(notification: NSNotification){
        self.todoScheduled.removeAll()
        loadData()
        self.tblTasks.reloadData()
    }
    
    var notificationSent = false // Used to track if notification has been sent
    var trackTime:String = ""

    func loadData() {
        self.todoScheduled.removeAll()
        
        // Load data from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: "todoObject") {
            let decoder = JSONDecoder()
            if let loadedTodos = try? decoder.decode([Todo].self, from: savedData) {
                // Store the loaded data in the todoScheduled dictionary, with date as the key and an array of todos as the value
                for todo in loadedTodos {
                    if let date = todo.date {
                        if todoScheduled[date] == nil {
                            self.todoScheduled[date] = [todo]
                        } else {
                            self.todoScheduled[date]?.append(todo)
                        }
                    }
                }
                
                // Reload the table view
                tblTasks.reloadData()
                
                // Check if the notification has already been sent
                if notificationSent {
                    return // Exit the function if the notification has already been sent
                }
                
                // Get the current time
                let currentTime = Date()
             //   print("Current time is \(currentTime)")
                // Create a date formatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss" // 24-hour time format
                
                // Get the string representation of the current time
                let currentTimeString = dateFormatter.string(from: currentTime)
                
              //  print("Current time String is \(currentTimeString)")
                
                // Get today's date as a string
                let today = Date()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let todayDateString = dateFormatter.string(from: today)
                
             //   print("Current date String is \(todayDateString)")
                
                // Check if there are todos for today
                if let todosForToday = todoScheduled[todayDateString] {
                    // Iterate over the todos for today
                    for todo in todosForToday {
                        // Check if the date and time of the todo match the current time
                        if todayDateString == todo.date && currentTimeString == todo.time {
                            // Send a notification
                            sendNotification(content: todo.title)
                            // Mark the notification as sent
                            // notificationSent = true
                            return // Exit the function to ensure only one notification is sent
                        }
                    }
                }
            }
        }
    }
    
    func sendNotification(content: String) {
        // Implement notification sending logic here
        print("Show Notification Now!!!!!")
        self.appDelegate?.scheduleNotification(notificationType: "Show Notification: \(content)")
        // notificationSent = false
    }

    // MARK: - Tableview DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoScheduled[selectedDate.toString()]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate.toString()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
        guard let task = todoScheduled[selectedDate.toString()]?[indexPath.row] else { return cell }
        
        cell.bind(task: task)
        
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Actions

    /**
     Handles the selection of a checkbox button in the table view cell.
     - Parameter sender: The checkbox button that was selected.
     */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        if var todo = todoScheduled[selectedDate.toString()]?[indexPath.row] {
            // Change the value of isCompleted
            todo.isCompleted = !todo.isCompleted
            todoScheduled[selectedDate.toString()]?[indexPath.row] = todo
            
            // Save the changes
            todo.updateToUserDefaults(title: todo.title, time: todo.time!, description: todo.description!, isCompleted: todo.isCompleted)
            
            // Update count
            if let count = UserDefaults.standard.value(forKey: "count") as? Int {
                UserDefaults.standard.setValue(count + 10, forKey: "count")
            } else {
                UserDefaults.standard.setValue(1, forKey: "count")
            }
            
            // Post a notification to refresh the shop
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshShop"), object: nil, userInfo: nil)
            
            // Reload the data
            loadData()
        }
    }

    /**
     Handles the press of the done button.
     - Parameter sender: The bar button item that was pressed.
     */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // delegate?.sendData(scheduledTasks: todoScheduled, newDate: selectedDate)
        // dismiss(animated: true, completion: nil)
        
        // Navigate to the AddTaskViewController
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: AddTaskViewController.storyboardID) as? AddTaskViewController else { return }
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }

    /**
     Handles the press of the change scope button.
     - Parameter sender: The bar button item that was pressed.
     */
    @IBAction func changeScopeButtonPressed(_ sender: UIBarButtonItem) {
        if tblTasks.isEditing {
            btnEditTable.title = "Edit"
            tblTasks.setEditing(false, animated: true)
        } else {
            btnEditTable.title = "Done"
            tblTasks.setEditing(true, animated: true)
        }
    }

    /**
     Handles the press of the show calendar button.
     - Parameter sender: The button that was pressed.
     */
    @IBAction func showCalendar(_ sender: Any) {
        if calendar.scope == .month {
            calendar.scope = .week
        } else {
            calendar.scope = .month
        }
    }
  
    
    /**
     Deletes a task at the specified index path.
     - Parameter indexPath: The index path of the task to delete.
     */
    func deleteTask(at indexPath: IndexPath) {
        guard let todoList = todoScheduled[selectedDate.toString()] else { return }
        
        let selectedTodo = todoList[indexPath.row]
        
        var todo = Todo(title: selectedTodo.title, date: selectedTodo.date, time: selectedTodo.time, description: selectedTodo.description, isCompleted: selectedTodo.isCompleted)
        
        // Delete the task from user defaults
        Todo.deleteTaskFromUserDefaults(title: todo.title, time: todo.time!, description: todo.description!, date: todo.date!)
        
        // Remove the task from the scheduled todo list
        todoScheduled[selectedDate.toString()]?.remove(at: indexPath.row)
        
        // Update the table view to reflect the deletion
        tblTasks.beginUpdates()
        tblTasks.deleteRows(at: [indexPath], with: .fade)
        tblTasks.endUpdates()
    }


    
}

// MARK: - Calendar Delegate

/**
 Provides the data source, delegate, and appearance customization for the calendar.
 */
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    /**
     Called when a date is selected on the calendar.
     - Parameter calendar: The calendar view object.
     - Parameter date: The selected date.
     - Parameter monthPosition: The position of the month containing the selected date.
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tblTasks.reloadData()
    }
    
    /**
     Called when the bounding rectangle of the calendar changes.
     - Parameter calendar: The calendar view object.
     - Parameter bounds: The new bounding rectangle of the calendar.
     - Parameter animated: A Boolean value indicating whether the change is animated or not.
     */
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    /**
     Retrieves the number of events for a specific date on the calendar.
     - Parameter calendar: The calendar view object.
     -Parameter date: The date for which the number of events is requested.
     - Returns: The number of events for the specified date.
     */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let tasks = todoScheduled[date.toString()], tasks.count > 0 { return 1 }
        return 0
    }
    
    /**
     Retrieves the default event colors for a specific date on the calendar.
     - Parameter calendar: The calendar view object.
     - Parameter appearance: The appearance object that defines the appearance of the calendar.
     - Parameter date: The date for which the default event colors are requested.
     - Returns: An array of UIColor objects representing the default event colors for the specified date.
     */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            return [UIColor.systemGray2]
        }
        return nil
    }
    
    /**
     Retrieves the event selection colors for a specific date on the calendar.
     - Parameter calendar: The calendar view object.
     - Parameter appearance: The appearance object that defines the appearance of the calendar.
     - Parameter date: The date for which the event selection colors are requested.
     - Returns: An array of UIColor objects representing the event selection colors for the specified date.
     */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            return [UIColor.systemGray2]
        }
        return nil
    }
}
