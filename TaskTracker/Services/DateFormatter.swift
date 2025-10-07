//
//  DateFormatter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 07.10.2025.
//

import Foundation

extension DateFormatter {
    static let ddMMYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
}
