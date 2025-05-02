//
//  Employee.swift
//  CompanyEmployees
//
//  Created by Miray Erten on 1.05.2025.
//

import Foundation
import CoreData

extension Employee {
    static func create(in context: NSManagedObjectContext, name: String, department: String, startDate: Date, endDate: Date? = nil, isStillWorking: Bool? = nil) -> Employee {
        let item = Employee(context: context)
        item.name = name
        item.department = department
        item.startDate = startDate
        item.endDate = endDate
        item.isStillWorking = false
        return item
    }
}
