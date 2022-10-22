//
//  MRZInfo.swift
//  MRZParser
//
//  Copyright © 2020 Safened - Fourthline B.V. All rights reserved.
//

import Foundation

/**
 *  Info parsed from the text found in the MRZ, check 'acceptable' property to see if the text
 *  passes the sanity checks. All information such as names etc.. are not guaranteed to
 *  be 100% correct because there are no check digits for these fields.
 *  Document number is guaranteed if acceptable == true.
 */
public class MRZInfo: NSObject {
    /**
     *  The names found on the document
     */
    public var names: [String] {
        get {
            return lastNames + firstNames
        }
    }
    
    /**
     *  The first name
     */
    public var firstName: String {
        get {
            return firstNames.joined(separator: " ")
        }
    }
    
    /**
     *  The last name
     */
    public var lastName: String {
        get {
            return lastNames.joined(separator: " ")
        }
    }
    
    /**
     *  The document number
     */
    public let documentNumber: String
    
    /**
     *  The nationality
     */
    public let nationality: String
    
    /**
     *  The date of birth of the person
     */
    public let dateOfBirth: String
    
    /**
     *  Acceptable is set to YES if all parsed field are not empty and have passed the sanity checks
     */
    public lazy var acceptable: Bool = isAcceptable()
    
    private let helper: MRZParserHelper?
    private let _isAcceptable: Bool
    
    /**
     *  Intialize with an MRZ text string
     *
     *  @param string A string, scanned from a travel document
     *  @return An MRZ info instance
     */
    public init(string: String) {
        // TODO: Parse fields from input string
        guard let helper = MRZParserHelper(string) else {
            _isAcceptable = false
            helper = nil
            
            self.documentNumber = ""
            self.nationality = ""
            self.dateOfBirth = ""
            self.firstNames = []
            self.lastNames = []
            return
        }
        self.helper = helper
        
        guard let person = helper.parseMRZCode() else {
            _isAcceptable = false
            self.documentNumber = ""
            self.nationality = ""
            self.dateOfBirth = ""
            self.firstNames = []
            self.lastNames = []
            return
        }
        
        _isAcceptable = helper.isValidMRZCode()
        self.documentNumber = person.documentNumber ?? ""
        self.nationality = person.nationality ?? ""
        self.dateOfBirth = person.dateOfBirth ?? ""
        self.firstNames = person.firstNames
        self.lastNames = person.lastNames
    }
 
    private func isAcceptable() -> Bool {
        return _isAcceptable
    }
    
    private let firstNames: [String]
    private let lastNames: [String]
    
    
}
