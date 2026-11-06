import Foundation
import HiIOSBase
import Testing

@Test
func nonEmptyStringRejectsEmptyInputAndInvalidDecodedValue() throws {
    #expect(NonEmptyString(rawValue: "") == nil)
    let value = try #require(NonEmptyString(rawValue: " a "))
    #expect(value.rawValue == " a ")
    #expect(try JSONDecoder().decode(NonEmptyString.self, from: JSONEncoder().encode(value)) == value)
    #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(NonEmptyString.self, from: Data("\"\"".utf8))
    }
}

@Test
func booleanParsingAcceptsOnlyExplicitTokens() {
    let token: Substring = " YES "[...]
    #expect(token.parsedBoolean == true)
    #expect("0".parsedBoolean == false)
    #expect("False".parsedBoolean == false)
    #expect("enable".parsedBoolean == nil)
    #expect("2".parsedBoolean == nil)
}

@Test
func roundedIntReportsOverflowAndUsesExplicitRoundingRule() {
    #expect(1.5.roundedInt() == 2)
    #expect((-1.5).roundedInt() == -2)
    #expect(2.5.roundedInt(roundingRule: .toNearestOrEven) == 2)
    #expect(Double.infinity.roundedInt() == nil)
    #expect(Double.nan.roundedInt() == nil)
    #expect(Double.greatestFiniteMagnitude.roundedInt() == nil)
}

@Test
func collectionOffsetUsesSliceStartAndRejectsOutOfBounds() {
    let slice = [10, 20, 30][1...]
    #expect(slice.element(atOffset: 0) == 20)
    #expect(slice.element(atOffset: 1) == 30)
    #expect(slice.element(atOffset: -1) == nil)
    #expect(slice.element(atOffset: 2) == nil)
    #expect([Int]().element(atOffset: 0) == nil)
}

@Test
func dictionaryKeyRemappingRejectsCollisions() throws {
    let input = ["a": 1, "b": 2]
    let mapped = try input.remapKeys { $0.uppercased() }
    #expect(mapped == ["A": 1, "B": 2])
    #expect(throws: DictionaryKeyMappingError.duplicateKey) {
        try ["a": 1, "A": 2].remapKeys { $0.lowercased() }
    }
    let optionalValues: [String: Int?] = ["a": nil, "A": 2]
    #expect(throws: DictionaryKeyMappingError.duplicateKey) {
        try optionalValues.remapKeys { $0.lowercased() }
    }
}
