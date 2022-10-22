//
//  MRZParserTests.swift
//  MRZParserTests
//
//  Copyright © 2020 Safened - Fourthline B.V. All rights reserved.
//

import XCTest
@testable import MRZParser

class MRZParserTests: XCTestCase {

    let typeTD3TestData = [
        // MRZ_ANNA_ERIKSSON_2LINE_TD3
        "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\n" +
        "L898902C<3UTO6908061F9406236ZE184226B<<<<<14",
        // MRZ_LOES_MEULENDIJK_2LINE_TD3_ZERO_CHECKDIGIT
        "P<NLDMEULENDIJK<<LOES<ALBERTINE<<<<<<<<<<<<<\n" +
        "XX00000000NLD7110195F1108280123456782<<<<<02",
        // MRZ_LOES_MEULENDIJK_2LINE_TD3_FILLER_CHECKDIGIT
        "P<NLDMEULENDIJK<<LOES<ALBERTINE<<<<<<<<<<<<<\n" +
        "XX00000000NLD7110195F1108280123456782<<<<<02",
        // MRZ_GERARD_ROBBERT_MARTINUS_SEBASTIAAN_VAN_NIEUWENHUIZEN_2LINE_TD3
        "P<NLDVAN<NIEUWENHUIZEN<<GERARD<ROBBERT<MARTI\n" +
        "XN01BC0150NLD7112247M1108268123456782<<<<<02",
        // MRZ_ERIKA_MUSTERMAN_2LINE_TD3
        "P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<<<<<<<<<\n" +
        "C11T002JM4D<<9608122F1310317<<<<<<<<<<<<<<<6",
        // MRZ_CHRISTIAN_MUSTERMAN_2LINE_TD3
        "P<D<<MUSTERMAN<<CHRISTIAN<<<<<<<<<<<<<<<<<<<\n" +
        "0000000000D<<8601067M1111156<<<<<<<<<<<<<<<6",
        // MRZ_VZOR_SPECIMEN_2LINE_TD3
        "P<CZESPECIMEN<<VZOR<<<<<<<<<<<<<<<<<<<<<<<<<\n" +
        "99009054<4CZE6906229F16072996956220612<<<<74",
        // MRZ_HAPPY_TRAVELER_2LINE_TD3
        "P<USATRAVELER<<HAPPY<<<<<<<<<<<<<<<<<<<<<<<<\n" +
        "1500000035USA5609165M0811150<<<<<<<<<<<<<<08",
        // MRZ_FRANK_AMOSS_2LINE_TD3
        "P<USAAMOSS<<FRANK<<<<<<<<<<<<<<<<<<<<<<<<<<<\n" +
        "0000780043USA5001013M1511169100000000<381564",
        // MRZ_LORENA_FERNANDEZ_2LINE_TD3
        "P<ARGFERNANDEZ<<LORENA<<<<<<<<<<<<<<<<<<<<<<\n" +
        "00000000A0ARG7903122F081210212300004<<<<<<86",
        // MRZ_KWOK_SUM_CHNCHUNG_2LINE_TD3
        "P<CHNCHUNG<<KWOK<SUM<<<<<<<<<<<<<<<<<<<<<<<<\n" +
        "K123455994CHN8008080F1702057HK8888888<<<<<36",
        // Willeke De Bruijn
        "P<NLDDE<BRUIJN<<WILLEKE<LIESELOTTE<<<<<<<<<<\n" +
        "XN2039LC36NLD6503101F1610202999999990<<<<<82"
    ]
    
    // Test all passport data from the test array
    func testMRZTypeTD3Success() {
        for input in self.typeTD3TestData {
            let mrzInfo = MRZInfo(string: input)
            XCTAssert(mrzInfo.acceptable , "MRZ was not acceptable " + input)
        }
    }
    
    // Valid input, check that all fields are parsed correctly
    func testMRZTypeTD3SuccessDetails() {
        let input = "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\n" +
        "L898902C<3UTO6908061F9406236ZE184226B<<<<<14"
        let mrzInfo = MRZInfo(string: input)
        XCTAssert(mrzInfo.acceptable , "MRZ was not acceptable " + input)
        XCTAssertEqual(mrzInfo.lastName, "ERIKSSON", "Last name does not match")
        XCTAssertEqual(mrzInfo.firstName, "ANNA MARIA", "First name does not match")
        XCTAssertEqual(mrzInfo.names.count, 3, "Number of names does not match")
        XCTAssertEqual(mrzInfo.documentNumber, "L898902C", "Document number does not match")
        XCTAssertEqual(mrzInfo.nationality, "UTO", "Nationality does not match")
        XCTAssertEqual(mrzInfo.dateOfBirth, "690806", "Date of birth does not match")
    }
    
    // The nationality and last name contain invalid characters
    func testMRZTypeTD3FailInvalidCharacters() {
        let input = "P<UT0ERIKS5ON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\n" +
        "L898902C<3UTO6908061F9406236ZE184226B<<<<<14"
        
        let mrzInfo = MRZInfo(string: input)
        XCTAssertFalse(mrzInfo.acceptable , "MRZ should not be acceptable " + input)
    }
    
    // Invalid input, missing data from the first line
    func testMRZTypeTD3FailInvalidLength() {
        let input = "P<UTOERIKSSON<<ANNA<MARIA<\n" +
        "L898902C<3UTO6908061F9406236ZE184226B<<<<<14"
        
        let mrzInfo = MRZInfo(string: input)
        XCTAssertFalse(mrzInfo.acceptable , "MRZ should not be acceptable " + input)
    }
    
    // Invalid input, the document number checksum is invalid (is 1, should be 3)
    func testMRZTypeTD3FailInvalidDocChecksum() {
        let input = "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\n" +
        "L898902C<1UTO6908061F9406236ZE184226B<<<<<14"
        
        let mrzInfo = MRZInfo(string: input)
        XCTAssertFalse(mrzInfo.acceptable , "MRZ should not be acceptable " + input)
    }

}
