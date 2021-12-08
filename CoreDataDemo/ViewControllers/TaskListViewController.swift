//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Raul Shafigin on 06.12.2021.
//

import UIKit
import CloudKit

enum Action {
    case save
    case update
}

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

extension TaskListViewController {
   
    
    @objc private func addNewTask() {
        showAlert(with: "New task", and: "What do you want to do?", action: .save)
    }
    
    private func showAlert(with title: String, and message: String, text: String? = nil, index: Int? = nil, action: Action) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            guard let index = index else { return }
            self.updateTask(text, index: index)
        }
        switch action {
        case .save:
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .update:
                alert.addAction(updateAction)
                alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.text = text
                }
            }
        present(alert, animated: true)
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: context)
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func updateTask(_ taskName: String, index: Int){
        taskList[index].title = taskName
        tableView.reloadData()
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func deleteTask(at index: Int) {
        let taskToDelete = taskList[index]
        taskList.remove(at: index)
        context.delete(taskToDelete)
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showAlert(with: "Updating", and: "Update your task", text: task.title, index: indexPath.row, action: .update)
    }
}

