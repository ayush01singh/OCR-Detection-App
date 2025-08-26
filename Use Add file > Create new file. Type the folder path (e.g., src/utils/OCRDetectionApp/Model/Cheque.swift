// Cheque.swift
// Model for representing a scanned cheque

import Foundation

struct Cheque {
    let chequeNumber: String
    let accountNumber: String
    let routingNumber: String
    let date: Date
    let payeeName: String
    let amountWords: String
    let amountNumeric: Double
    let signatureImage: Data?
    let bankName: String
    let branch: String
}
