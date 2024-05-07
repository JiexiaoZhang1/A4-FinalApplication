import Foundation

// A struct representing a Todo item
struct Todo: Codable {
    var title: String
    var date: String?
    var time: String?
    var description: String?
    var isCompleted: Bool = false
    
    // Update the Todo item in UserDefaults
    mutating func updateToUserDefaults(title: String, time: String, description: String, isCompleted: Bool) {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // Find the Todo object to update
        if let index = allTodos.firstIndex(where: { $0.title == (title ?? "") && $0.time == (time ?? "") && $0.description == (description ?? "") }) {
            // Update the isCompleted property
            allTodos[index].isCompleted = isCompleted
            
            // Sort the array
            allTodos.sort { (todo1, todo2) -> Bool in
                // Compare based on sorting logic, such as sorting by time
                return (todo1.time ?? "") < (todo2.time ?? "")
            }
            
            // Save the updated array to UserDefaults
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(allTodos) {
                UserDefaults.standard.set(encodedData, forKey: "todoObject")
                print("Todo saved to UserDefaults")
            }
        }
    }
    
    // Delete a Todo item from UserDefaults
    static func deleteTaskFromUserDefaults(title: String, time: String, description: String, date: String) {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // Find the Todo object to delete
        if let index = allTodos.firstIndex(where: { $0.title == title && $0.time == time && $0.description == description && $0.date == date }) {
            allTodos.remove(at: index)
            
            // Save the updated array to UserDefaults
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(allTodos) {
                UserDefaults.standard.set(encodedData, forKey: "todoObject")
                print("Todo deleted from UserDefaults")
            }
        }
    }
}

// Equatable extension for Todo struct
extension Todo: Equatable {
    static let empty = Todo(title: "", date: "", time: "", description: "")
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return (lhs.title == rhs.title &&
                    lhs.date == rhs.date &&
                    lhs.time == rhs.time &&
                    lhs.date == rhs.date &&
                    lhs.description == rhs.description &&
                    lhs.isCompleted == rhs.isCompleted)
    }
}

// Extensions for Todo struct
extension Todo {
    // Save a single Todo item to UserDefaults
    func saveToUserDefaults() {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // Check if the current task already exists in the list
        if let index = allTodos.firstIndex(where: { $0.title == self.title }) {
            // If a task with the same title as the current task is found, replace it
            allTodos[index] = self
        } else {
            // Otherwise, add the current task to the end of the list
            allTodos.append(self)
        }
        
        // Save the entire task list to UserDefaults
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(allTodos) {
            UserDefaults.standard.set(encodedData, forKey: "todoObject")
            print("Todo saved to UserDefaults")
        }
    }
    
    // Load a single Todo item from UserDefaults
    static func loadFromUserDefaults() -> Todo? {
        if let savedData = UserDefaults.standard.data(forKey: "todoObject") {
            let decoder = JSONDecoder()
            if let loadedTodo = try? decoder.decode(Todo.self, from: savedData) {
                return loadedTodo
            }
        }
        return nil
    }
    
    // Load all Todo items from UserDefaults
    static func loadAllFromUserDefaults() -> [Todo]? {
        if let savedData = UserDefaults.standard.data(forKey: "todoObject") {
            let decoder = JSONDecoder()
            if let loadedTodos = try? decoder.decode([Todo].self, from: savedData) {
                return loadedTodos
            }
        }
        return nil
    }
}

