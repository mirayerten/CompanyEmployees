//
//  EmployeeDetailViewController.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//

import UIKit
import CoreData

class EmployeeFormViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    @IBOutlet weak var hireDatePicker: UIDatePicker!
    @IBOutlet weak var terminationSwitch: UISwitch!
    @IBOutlet weak var terminationDatePicker: UIDatePicker!
    @IBOutlet weak var nameLabel: UILabel!    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var hireDateLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var employeeToEdit: Employee?
    var onSave: (() -> Void)?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let departments = ["IT", "Satış", "Pazarlama", "Muhasebe"]
    var departmentPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.keyboardType = .numberPad
        phoneField.delegate = self
        departmentPicker.delegate = self
        departmentPicker.dataSource = self
        departmentField.inputView = departmentPicker
        terminationSwitch.isOn = true
        dateLabel.isHidden = true
        terminationDatePicker.isHidden = true
        terminationDatePicker.isEnabled = false
        terminationSwitch.addTarget(self, action: #selector(toggleTermination), for: .valueChanged)
        fillIfEditing()
    }

    @objc func toggleTermination() {
        let isTerminated = terminationSwitch.isOn
        terminationDatePicker.isHidden = isTerminated
        terminationDatePicker.isEnabled = !isTerminated
        dateLabel?.isHidden = isTerminated
    }

    private func fillIfEditing() {
        guard let emp = employeeToEdit else { return }
        nameField.text = emp.name
        emailField.text = emp.email
        phoneField.text = emp.phone
        departmentField.text = emp.department
        hireDatePicker.date = emp.hireDate ?? Date()
        if let term = emp.terminationDate {
            terminationSwitch.isOn = true
            terminationDatePicker.isEnabled = true
            terminationDatePicker.date = term
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }

    @IBAction func saveTapped(_ sender: Any) {
        let hireDate = hireDatePicker.date
        if hireDate > Date() {
            let alert = UIAlertController(title: "Geçersiz Tarih", message: "İşe giriş tarihi bugünden ileri olamaz.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        guard
            let name = nameField.text, !name.isEmpty,
            let email = emailField.text, !email.isEmpty,
            let phone = phoneField.text, !phone.isEmpty,
            let department = departmentField.text, !department.isEmpty
        else {
            let alert = UIAlertController(title: "Eksik Bilgi", message: "Lütfen tüm alanları doldurun.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        let emp = employeeToEdit ?? Employee(context: context)
        emp.name = nameField.text
        emp.email = emailField.text
        emp.phone = phoneField.text
        emp.department = departmentField.text
        emp.hireDate = hireDatePicker.date
        emp.terminationDate = terminationSwitch.isOn ? terminationDatePicker.date : nil

        do {
            try context.save()
            onSave?()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return departments.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return departments[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        departmentField.text = departments[row]
    }
}





/*
import UIKit
import CoreData

protocol DetailViewControllerDelegate: AnyObject{
    func detailViewControllerDidSave()
}

class EmployeeDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    @IBOutlet weak var departmentPicker: UIPickerView!
  
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var isStillWorkingLabel: UILabel!
    @IBOutlet weak var isStillworkingSwitch: UISwitch!

    
    weak var delegate: DetailViewControllerDelegate?
    var item: Employee?
    private var isNewItem: Bool { item == nil }
    let departments: [String] = ["İnsan Kaynakları", "IT", "Satış"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded view controller: \(type(of: self))")
        configureNavigationBar()
        loadItemData()
        isStillworkingSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
                updateEndDateVisibility()
    }
    
    private func configureNavigationBar() {
        title = isNewItem ? "Yeni Çalışan" : "Düzenle"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    @IBAction private func saveButtonTapped() {
        guard let title = nameTextField.text, !title.isEmpty else {
            showAlert(message: "Lütfen bir isim giriniz")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if isNewItem {
            let newItem = Employee.create(
                in: context,
                name: title,
                department: "IT",
                startDate: startDatePicker.date,
              //  endDate: isStillworkingSwitch.isOn ? nil : endDatePicker.date,
                isStillWorking: isStillworkingSwitch.isOn
            )
        } else {
            item?.name = title
            item?.isStillWorking = isStillworkingSwitch.isOn
            item?.startDate = startDatePicker.date
           // item?.endDate = isStillworkingSwitch.isOn ? nil : endDatePicker.date
            
        }
        do {
                try context.save()
                delegate?.detailViewControllerDidSave()
                navigationController?.popViewController(animated: true)
            } catch {
                showAlert(message: "Kaydetme sırasında hata oluştu")
            }
    
    }

    private func loadItemData() {
        guard let item = item else { return }
        
        nameTextField.text = item.name
        startDatePicker.date = item.startDate ?? Date()
        isStillworkingSwitch.isOn = item.isStillWorking
     //   endDatePicker.date = item.endDate ?? Date()
        updateEndDateVisibility()
    }
    
    @objc private func switchValueChanged() {
            updateEndDateVisibility()
    }
    
    private func updateEndDateVisibility() {
        let shouldShowEndDate = !isStillworkingSwitch.isOn
     //   endDateLabel.isHidden = !shouldShowEndDate
     //   endDatePicker.isHidden = !shouldShowEndDate
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Hata",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
*/
