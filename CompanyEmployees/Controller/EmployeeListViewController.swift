//
//  EmployeesListViewController.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//


import UIKit
import CoreData

class EmployeeListViewController: UITableViewController {

    var employees: [Employee] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Çalışanlar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEmployee))
        fetchEmployees()
    }

    @objc func addEmployee() {
        performSegue(withIdentifier: "showForm", sender: nil)
    }

    func fetchEmployees() {
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        do {
            employees = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch error: \(error)")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let employee = employees[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
       // cell.textLabel?.numberOfLines = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "tr_TR")

        let name = employee.name ?? ""
        let department = employee.department ?? ""
        let hireDate = employee.hireDate != nil ? dateFormatter.string(from: employee.hireDate!) : "-"
        
        cell.textLabel?.text = name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        cell.detailTextLabel?.text = "Departman: \(department) | Giriş: \(hireDate)"
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil") { _, _, _ in
            let emp = self.employees[indexPath.row]
            self.context.delete(emp)
            try? self.context.save()
            self.fetchEmployees()
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return UISwipeActionsConfiguration(actions: [delete])
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            self.performSegue(withIdentifier: "showForm", sender: self.employees[indexPath.row])
        }
        edit.backgroundColor = .systemBlue
        let config = UISwipeActionsConfiguration(actions: [edit])
        config.performsFirstActionWithFullSwipe = false
        return UISwipeActionsConfiguration(actions: [edit])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showForm",
           let vc = segue.destination as? EmployeeFormViewController {
            vc.employeeToEdit = sender as? Employee
            vc.onSave = { self.fetchEmployees() }
        }
    }
}



/*
import UIKit
import CoreData

class EmployeeListViewController: UITableViewController {
 
    private var items: [Employee] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
    }
    
    private func fetchItems() {
        let fetchRequest = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)] // NSSortDescriptor sıralama için kullanılıyor
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? EmployeeDetailViewController {
            detailVC.delegate = self
            
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                detailVC.item = items[indexPath.row]
            }
        } else {
            print("segue.destination is not EmployeeDetailViewController")
        }
    }
    
    private func deleteItem(_ item: Employee) {
        context.delete(item)
        saveContext()
        fetchItems()
    }
    
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Miray"
        return cell
    }
     */
}

extension EmployeeListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        
        if let startDate = item.startDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            content.secondaryText = formatter.string(from: startDate)
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailVC", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.deleteItem(item)
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { [weak self] _, _, completion in
            let cell = tableView.cellForRow(at: indexPath)
            self?.performSegue(withIdentifier: "showDetailVC", sender: cell)
            completion(true)
        }
        editAction.backgroundColor = UIColor.systemBlue
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension EmployeeListViewController: DetailViewControllerDelegate{
    func detailViewControllerDidSave() {
            fetchItems()
        }
}
*/
