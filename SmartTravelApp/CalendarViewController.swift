import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Properties
    
    static let storyboardID = "calendarTask"

    var todoScheduled: [String : [Todo]] = [:]
    var selectedDate = Date()
    var timer: Timer?
    // MARK: - View Lifecycle
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册观察者监听数据变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshHome(notification:)), name: NSNotification.Name(rawValue: "refreshHome"), object: nil)

        
        loadData()
        tblTasks.reloadData()
        

        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTasks.rowHeight = UITableView.automaticDimension
        

        calendar.select(selectedDate)
        

        calendarHeightConstraint.constant = self.view.bounds.height / 2

        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = calendar.calendarWeekdayView.weekdayLabels[0].textColor
   
        calendar.scope = .week
        
        startTimer()
        
        //show notification
       /* DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("nana")
            self.appDelegate?.scheduleNotification(notificationType: "hello word")
        }
        */
        
     
     }
   
    @objc func checkTime() {
      
       
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForTodos), userInfo: nil, repeats: true)
    }

    @objc func checkForTodos() {
        // 在这里执行你的检测逻辑
        // 检查是否有待办事项...
        // 如果有，打印数据和执行其他操作
      //  print("Checking for todos...")
        loadData() // 调用你的 loadData() 方法
    }

    func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func refreshHome(notification: NSNotification){
        self.todoScheduled.removeAll()
        loadData()
        self.tblTasks.reloadData()
    }
    
    var notificationSent = false // 用于跟踪通知是否已发送
    var trackTime:String = ""

    func loadData() {
        self.todoScheduled.removeAll()
        
        // 从 UserDefaults 中加载数据
        if let savedData = UserDefaults.standard.data(forKey: "todoObject") {
            let decoder = JSONDecoder()
            if let loadedTodos = try? decoder.decode([Todo].self, from: savedData) {
                // 将加载的数据存储到 todoScheduled 字典中，以日期为键，待办事项数组为值
                for todo in loadedTodos {
                    if let date = todo.date {
                        if todoScheduled[date] == nil {
                            self.todoScheduled[date] = [todo]
                        } else {
                            self.todoScheduled[date]?.append(todo)
                        }
                    }
                }
                
                // 重新加载表格视图
                tblTasks.reloadData()
               
                // 检查通知是否已发送
                    if notificationSent {
                        return // 如果通知已发送，则退出函数
                    }

                    // 获取当前时间
                    let currentTime = Date()
                    
                    // 创建日期格式化器
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss" // 24小时制时间格式
                    
                    // 获取当前时间的字符串表示
               
                    let currentTimeString = dateFormatter.string(from: currentTime)
              
                    

                    // 获取今天的日期字符串
                    let today = Date()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todayDateString = dateFormatter.string(from: today)
                print("Current time",currentTimeString)
               
                    // 检查是否有今天的待办事项
                    if let todosForToday = todoScheduled[todayDateString] {
                        // 遍历今天的待办事项
                        for todo in todosForToday {
                            // 检查待办事项的日期和时间是否与当前时间匹配
                            if todayDateString == todo.date && currentTimeString == todo.time
                               
                            {

                                // 发送通知
                                sendNotification(content: todo.title)
                                // 标记通知已发送
                              //  notificationSent = true
                                return // 退出函数，以确保只发送一次通知
                            }
                        }
                    }
                
                
              
            }
        }
    }
    
    func sendNotification(content:String) {
        // 在这里实现发送通知的逻辑
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
    

    @objc func checkboxSelection(_ sender: CheckUIButton) {

        guard let indexPath = sender.indexPath else { return }
        
        if var todo = todoScheduled[selectedDate.toString()]?[indexPath.row] {
            // 更改 isCompleted 值
            todo.isCompleted = !todo.isCompleted
            todoScheduled[selectedDate.toString()]?[indexPath.row] = todo
            
            // 保存更改
            todo.updateToUserDefaults(title: todo.title, time: todo.time!, description: todo.description!, isCompleted: todo.isCompleted)
            
            // 更新 count
            if let count = UserDefaults.standard.value(forKey: "count") as? Int {
                UserDefaults.standard.setValue(count + 10, forKey: "count")
            } else {
                UserDefaults.standard.setValue(1, forKey: "count")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshShop"), object: nil, userInfo: nil)
            loadData()
        }
    }



    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
     //   delegate?.sendData(scheduledTasks: todoScheduled, newDate: selectedDate)
       // dismiss(animated: true, completion: nil)
        
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: AddTaskViewController.storyboardID) as? AddTaskViewController else { return }
        
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }
    

    @IBAction func changeScopeButtonPressed(_ sender: UIBarButtonItem) {
        if tblTasks.isEditing {
            btnEditTable.title = "Edit"
            tblTasks.setEditing(false, animated: true)
        } else {
            btnEditTable.title = "Done"
            tblTasks.setEditing(true, animated: true)
        }
    }
    
    @IBAction func showCalendar(_ sender: Any) {
        if calendar.scope == .month {
            calendar.scope = .week
      
        } else {
            calendar.scope = .month
      
        }
    }
    
  
    
    func deleteTask(at indexPath: IndexPath) {
        guard let todoList = todoScheduled[selectedDate.toString()] else { return }
        
        let selectedTodo = todoList[indexPath.row]
        
        var todo = Todo(title: selectedTodo.title, date: selectedTodo.date, time: selectedTodo.time, description: selectedTodo.description, isCompleted: selectedTodo.isCompleted)
        Todo.deleteTaskFromUserDefaults(title: todo.title, time: todo.time!, description: todo.description!, date: todo.date!)
        

        todoScheduled[selectedDate.toString()]?.remove(at: indexPath.row)
        
        tblTasks.beginUpdates()
        tblTasks.deleteRows(at: [indexPath], with: .fade)
        tblTasks.endUpdates()
    }



    
}

// MARK: - Calendar Delegate

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tblTasks.reloadData()
    }
    

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let tasks = todoScheduled[date.toString()], tasks.count > 0 { return 1 }
        return 0
    }
    

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {

            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
     
            return [UIColor.systemGray2]
        }
        return nil
    }
    

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {

            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }

            return [UIColor.systemGray2]
        }
        return nil
    }
    
    
    
    
}
