//
//  ServiceError.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/08/2025.
//

import Foundation

enum ServiceError: Error {
    case missingDocumentID
    case unknownError
    case dataConversionError
    case unauthenticateUser
    }
