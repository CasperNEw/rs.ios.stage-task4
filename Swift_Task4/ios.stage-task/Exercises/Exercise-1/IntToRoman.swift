import Foundation

public extension Int {

    var roman: String? {
        guard self >= 1, self <= 3999
        else { return nil }
        let conversionTable: [(intNumber: Int, romanNumber: String)] =
            [(1000, "M"),
             (900, "CM"),
             (500, "D"),
             (400, "CD"),
             (100, "C"),
             (90, "XC"),
             (50, "L"),
             (40, "XL"),
             (10, "X"),
             (9, "IX"),
             (5, "V"),
             (4, "IV"),
             (1, "I")]
        var roman = ""
        var remainder = 0

        for entry in conversionTable {
            let quotient = (self - remainder) / entry.intNumber
            remainder += quotient * entry.intNumber
            roman += String(repeating: entry.romanNumber, count: quotient)
        }
        return roman
    }
}
