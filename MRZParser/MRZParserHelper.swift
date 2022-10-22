//
//  MRZParserHelper.swift
//  MRZParser
//
//  Created by Moein Barzegaran on 10/22/22.
//  Copyright © 2022 Safened - Fourthline B.V. All rights reserved.
//

import Foundation

class MRZParserHelper {
    
    class PersonIdentity {
        var firstNames: [String] = []
        var lastNames: [String] = []
        var nationality: String?
        var dateOfBirth: String?
        var expirationDate: String?
        var documentNumber: String?
        var sex: String?
        var personalNumber: String?
    }
    
    private let dataWeightTable: [String: Int] = [
        "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
        "<": 0,
        "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15, "G": 16, "H": 17, "I": 18, "J": 19, "K": 20, "L": 21, "M": 22, "N": 23, "O": 24, "P": 25, "Q": 26, "R": 27, "S": 28, "T": 29, "U": 30, "V": 31, "W": 32, "X": 33, "Y": 34, "Z": 35
    ]
    
    private let input: String
    private var firstLine: String = ""
    private var secondLine: String = ""
    private var isValid: Bool = false
    
    init?(_ input: String) {
        self.input = input
        guard input.contains("\n") else { return nil }
        let twoLineData = Array(input.split(separator: "\n"))
        guard let firstLineData = twoLineData.first, let secondLineData = twoLineData.last else { return nil }
        
        let firstLine = String(firstLineData)
        let secondLine = String(secondLineData)
        guard firstLine.count == 44 && secondLine.count == 44 else { return nil }
        
        self.firstLine = firstLine
        self.secondLine = secondLine
    }
    
    func getCheckDigit(_ text: String) -> String {
        let value = text.compactMap { dataWeightTable[String($0)] }
        
        let weighting = [0: 7, 1: 3, 2: 1]
        var iterate = 0
        
        var sum = 0
        for item in value {
            guard let weight = weighting[iterate] else { fatalError("Something wrong happened") }
            sum += item * weight
            
            if iterate < 2 {
                iterate += 1
            } else {
                iterate = 0
            }
        }
        
        return "\(sum%10)"
    }
    
    // MARK: Check specific chunk with it's check digit to be valid
    func isValid(chunk: String) -> Bool {
        guard !chunk.isEmpty && chunk.count > 1 else { return false }
        guard let givenCheckDigit = chunk.last else { return false }
        let sample = String(chunk.dropLast())
        return getCheckDigit(sample) == "\(givenCheckDigit)"
    }
    
    // MARK: Check both first and second line and parse it
    func parseMRZCode() -> PersonIdentity? {
        let personIdentity: PersonIdentity = .init()
        
        parseFirstLine(person: personIdentity, firstLine)
        parseSecondLine(person: personIdentity, secondLine)
        
        return personIdentity
    }
    
    func parseFirstLine(person: PersonIdentity ,_ input: String) {
        let names = getNames(input)
        person.firstNames = names.firstNames
        person.lastNames = names.lastNames
    }
    
    func parseSecondLine(person: PersonIdentity, _ input: String) {
        person.documentNumber = getDocumentNumber(input)
        person.nationality = getNationality(input)
        person.dateOfBirth = getDateOfBirth(input)
        person.sex = getSex(input)
        person.expirationDate = getExpirationDate(input)
        person.personalNumber = getPersonalNumber(input)
    }
    
    func getNames(_ input: String) -> (firstNames: [String], lastNames: [String]) {
        let names = getDesiredRangeOfString(from: input, start: 5, end: 43)
        let splitted = names.components(separatedBy: "<<")
        let lastNames = splitted[0].split(separator: "<").map({ String($0) })
        let firstNames = splitted[1].split(separator: "<").map({ String($0) })
        return (firstNames, lastNames)
    }
    
    func getDocumentNumber(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 0, end: 8).replacingOccurrences(of: "<", with: "")
    }
    
    func getNationality(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 10, end: 12)
    }
    
    func getDateOfBirth(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 13, end: 18)
    }
    
    func getSex(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 20, end: 20)
    }
    
    func getExpirationDate(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 21, end: 26)
    }
    
    func getPersonalNumber(_ input: String) -> String {
        return getDesiredRangeOfString(from: input, start: 28, end: 41)
    }
    
    func getDesiredRangeOfString(from input: String, start: Int, end: Int) -> String {
        let start = input.index(input.startIndex, offsetBy: start)
        let end = input.index(input.startIndex, offsetBy: end)
        let range = start...end
        return String(input[range])
    }
    
    func isValidMRZCode() -> Bool {
        // Calculate the check digit over digits 1–10, 14–20, and 22–43
        let secondLineCheckDigitText = getDesiredRangeOfString(from: secondLine, start: 0, end: 9) +
        getDesiredRangeOfString(from: secondLine, start: 13, end: 19) +
        getDesiredRangeOfString(from: secondLine, start: 21, end: 42) +
        getDesiredRangeOfString(from: secondLine, start: 43, end: 43)
        
        let isWholeSecondLineCheckDigitValid = isValid(chunk: secondLineCheckDigitText)
        
        // Check digit over digits 1–9
        let isPassportNumberValid = isValid(chunk: getDesiredRangeOfString(from: secondLine, start: 0, end: 9))
        
        // Check digit over digits 14–19
        let isDateOfBirthValid = isValid(chunk: getDesiredRangeOfString(from: secondLine, start: 13, end: 19))
        
        // Check digit over digits 22–27
        let isExpirationDateValid = isValid(chunk: getDesiredRangeOfString(from: secondLine, start: 21, end: 27))
        
        // Check digit over digits 29–42 (may be < if all characters are <)
        let personalNumber = getDesiredRangeOfString(from: secondLine, start: 28, end: 42)
        let isPersonalNumberValid = personalNumber.replacingOccurrences(of: "<", with: "").isEmpty || personalNumber.count < 2 ? true : isValid(chunk: personalNumber)
        
        // Check names validation
        let names = getNames(input)
        let decimalCharacters = CharacterSet.decimalDigits
        let isNamesValid = (names.firstNames + names.lastNames).joined().rangeOfCharacter(from: decimalCharacters) == nil
        
        return isPassportNumberValid &&
        isDateOfBirthValid &&
        isExpirationDateValid &&
        isPersonalNumberValid &&
        isWholeSecondLineCheckDigitValid &&
        isNamesValid
    }
    
}
