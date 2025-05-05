//
//  Employee.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//

import Foundation
import CoreData

extension Employee {
    static func create(in context: NSManagedObjectContext, name: String, email: String, phone: String, department: String, hireDate: Date, terminationDate: Date? = nil) -> Employee {
        let item = Employee(context: context)
        item.name = name
        item.email = email
        item.phone = phone
        item.department = department
        item.hireDate = hireDate
        item.terminationDate = terminationDate
        return item
    }
}
