//
//  EmployeeDetailViewController.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//

import UIKit
import CoreData

class EmployeeDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return departments.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return departments[row]
    }

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var departmentPicker: UIPickerView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var isStillWorkingLabel: UILabel!
    @IBOutlet weak var isStillWorkingSwitch: UISwitch!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var employeeToEdit: Employee?
    let departments = ["İnsan Kaynakları", "IT", "Satış"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEmployee()
    }
    
    
    
    private func updateEmployee() {
        endDatePicker.isHidden = isStillWorkingSwitch.isOn
        endDateLabel.isHidden = isStillWorkingSwitch.isOn
        //Eğer düzenlenecek çalışan varsa dolduruyor
        if let employee = employeeToEdit {
            nameTextField.text = employee.name
            if let dept = employee.department, let index = departments.firstIndex(of: dept){
                departmentPicker.selectRow(index, inComponent: 0, animated: false)
            }
            startDatePicker.date = employee.startDate ?? Date()
            isStillWorkingSwitch.isOn = employee.isStillWorking
            if let endDate = employee.endDate {
                endDatePicker.date = endDate
            }
        }
    }
    
    private func selectedDepartment() -> String {
        let selectedRow = departmentPicker.selectedRow(inComponent: 0)
        return departments[selectedRow]
    }
    
    @IBAction func isStillWorkingSwitch(_ sender: UISwitch) {
        updateEmployee()
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let employee = employeeToEdit ?? Employee(context: context)
        employee.name = nameTextField.text
        employee.department = selectedDepartment()
        employee.startDate = startDatePicker.date
        employee.isStillWorking = isStillWorkingSwitch.isOn
        employee.endDate = isStillWorkingSwitch.isOn ? nil : endDatePicker.date
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("hata")
        }
    }
}
