// ChequeValidationResult.swift
// Model for cheque validation results

import Foundation

enum ChequeValidationStatus {
    case valid
    case invalid([String]) // List of validation errors
}

struct ChequeValidationResult {
    let status: ChequeValidationStatus
    let validatedCheque: Cheque?
}
