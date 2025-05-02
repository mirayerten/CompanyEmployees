//
//  EmployeesListViewController.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//

import UIKit
import CoreData

class EmployeeListViewController: UITableViewController {
    
    private var items : [Employee] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var employeeTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToEmployeeDetailVC" {
            if let destinationVC = segue.destination as? EmployeeDetailViewController {
                if let selectedEmployee = sender as? Employee {
                    destinationVC.employeeToEdit = selectedEmployee
                } else {
                    destinationVC.employeeToEdit = nil // Yeni kayıt
                }
            }
        }
    }

    @IBAction func addEmployee(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToEmployeeDetailVC", sender: nil)
    }
}
extension EmployeeListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        let employee = items[indexPath.row]
        cell.textLabel?.text = employee.name
        return cell
    }

    // Swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let employeeToDelete = items[indexPath.row]
            context.delete(employeeToDelete)
            do {
                try context.save()
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Silme hatası: \(error)")
            }
        }
    }

    // Swipe to edit (custom action)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { (_, _, completionHandler) in
            let selectedEmployee = self.items[indexPath.row]
            self.performSegue(withIdentifier: "ToEmployeeDetailVC", sender: selectedEmployee)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (_, _, completionHandler) in
            let employeeToDelete = self.items[indexPath.row]
            self.context.delete(employeeToDelete)
            do {
                try self.context.save()
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                completionHandler(true)
            } catch {
                print("Silme hatası: \(error)")
                completionHandler(false)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // Verileri çekmek için
    func fetchEmployees() {
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        do {
            items = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch hatası: \(error)")
        }
    }
}
