//
//  EmployeeDetailViewController.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//




import UIKit
import CoreData

protocol EmployeeDetailDelegate: AnyObject {
    func didSaveEmployee()
}

class EmployeeFormViewController: UIViewController {

    var employee: Employee?
    weak var delegate: EmployeeDetailDelegate?

    let nameField = UITextField()
    let emailField = UITextField()
    let phoneField = UITextField()
    let departmentField = UITextField()
    let hireDatePicker = UIDatePicker()
    let terminationDatePicker = UIDatePicker()
    let terminationSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = employee == nil ? "Çalışan Ekle" : "Düzenle"
        view.backgroundColor = .white
        setupForm()
        fillFormIfNeeded()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .done, target: self, action: #selector(saveEmployee))
    }

    func setupForm() {
        // Form alanlarını düzenleyin - AutoLayout ile yerleştirme yapılmalı
        // Basit örnek: dikey stackView
        let stack = UIStackView(arrangedSubviews: [nameField, emailField, phoneField, departmentField, hireDatePicker, terminationSwitch, terminationDatePicker])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        nameField.placeholder = "İsim"
        emailField.placeholder = "Email"
        phoneField.placeholder = "Telefon"
        departmentField.placeholder = "Departman"
        hireDatePicker.datePickerMode = .date
        terminationDatePicker.datePickerMode = .date
        terminationDatePicker.isEnabled = false
        terminationSwitch.addTarget(self, action: #selector(toggleTerminationDate), for: .valueChanged)
    }

    func fillFormIfNeeded() {
        guard let emp = employee else { return }
        nameField.text = emp.name
        emailField.text = emp.email
        phoneField.text = emp.phone
        departmentField.text = emp.department
        hireDatePicker.date = emp.hireDate ?? Date()
        if let termination = emp.terminationDate {
            terminationSwitch.isOn = true
            terminationDatePicker.isEnabled = true
            terminationDatePicker.date = termination
        }
    }

    @objc func toggleTerminationDate() {
        terminationDatePicker.isEnabled = terminationSwitch.isOn
    }

    @objc func saveEmployee() {
        let context = PersistenceController.shared.container.viewContext

        let emp = employee ?? Employee(context: context)
        emp.name = nameField.text
        emp.email = emailField.text
        emp.phone = phoneField.text
        emp.department = departmentField.text
        emp.hireDate = hireDatePicker.date
        emp.terminationDate = terminationSwitch.isOn ? terminationDatePicker.date : nil

        do {
            try context.save()
            delegate?.didSaveEmployee()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Save error: \(error)")
        }
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
