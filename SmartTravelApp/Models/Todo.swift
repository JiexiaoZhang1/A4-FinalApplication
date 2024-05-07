//
//  Todo.swift
//  TaskApp
//
//  Created by student on 1/5/2024.
//

import Foundation

struct Todo: Codable {
    var title: String
    var date: String?
    var time: String?
    var description: String?
    var isCompleted: Bool = false
    
    mutating func updateToUserDefaults(title: String, time: String, description: String, isCompleted: Bool) {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // 查找要更新的 Todo 对象
        if let index = allTodos.firstIndex(where: { $0.title == (title ?? "") && $0.time == (time ?? "") && $0.description == (description ?? "") }) {
            // 更新 isCompleted 属性
            allTodos[index].isCompleted = isCompleted
            
            // 对数组进行排序
            allTodos.sort { (todo1, todo2) -> Bool in
                // 根据需要的排序逻辑进行比较，例如按照时间排序
                return (todo1.time ?? "") < (todo2.time ?? "")
            }
            
            // 将更新后的数组保存到 UserDefaults 中
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(allTodos) {
                UserDefaults.standard.set(encodedData, forKey: "todoObject")
                print("Todo saved to UserDefaults")
            }
        }
    }
    
    
    static func deleteTaskFromUserDefaults(title: String, time: String, description: String, date: String) {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // 查找要删除的Todo对象
        if let index = allTodos.firstIndex(where: { $0.title == title && $0.time == time && $0.description == description && $0.date == date }) {
            allTodos.remove(at: index)
            
            // 将更新后的数组保存到UserDefaults中
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(allTodos) {
                UserDefaults.standard.set(encodedData, forKey: "todoObject")
                print("Todo deleted from UserDefaults")
            }
        }
    }

    

}

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

extension Todo {
    func saveToUserDefaults() {
        var allTodos = Todo.loadAllFromUserDefaults() ?? []
        
        // 查找当前任务是否已存在于列表中
        if let index = allTodos.firstIndex(where: { $0.title == self.title }) {
            // 如果找到了与当前任务标题相同的任务，则替换它
            allTodos[index] = self
        } else {
            // 否则，将当前任务添加到列表末尾
            allTodos.append(self)
        }
        
        // 将整个任务列表保存到 UserDefaults 中
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(allTodos) {
            UserDefaults.standard.set(encodedData, forKey: "todoObject")
            print("Todo saved to UserDefaults")
        }
    }
    
    static func loadFromUserDefaults() -> Todo? {
        if let savedData = UserDefaults.standard.data(forKey: "todoObject") {
            let decoder = JSONDecoder()
            if let loadedTodo = try? decoder.decode(Todo.self, from: savedData) {
                return loadedTodo
            }
        }
        return nil
    }
    
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
