//
// Copyright 2022 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging

extension CreditOrDebitCardDonationViewController {
    enum FormField {
        case cardNumber
        case expirationDate
        case cvv
    }

    enum FormState: Equatable {
        /// At least one of the form's fields are invalid.
        case invalid(invalidFields: Set<FormField>)

        /// The form is potentially valid, but not ready to submit yet.
        case potentiallyValid

        /// The form is fully valid and ready to submit.
        case fullyValid(creditOrDebitCard: Stripe.PaymentMethod.CreditOrDebitCard)
    }

    static func formState(
        cardNumber rawNumber: String?,
        isCardNumberFieldFocused: Bool,
        expirationDate rawExpirationDate: String?,
        cvv rawCvv: String?
    ) -> FormState {
        var invalidFields = Set<FormField>()
        var hasPotentiallyValidFields = false

        let numberForValidation = (rawNumber ?? "").removeCharacters(characterSet: .whitespaces)
        let numberValidity = CreditAndDebitCards.validity(
            ofNumber: numberForValidation,
            isNumberFieldFocused: isCardNumberFieldFocused
        )
        switch numberValidity {
        case .invalid: invalidFields.insert(.cardNumber)
        case .potentiallyValid: hasPotentiallyValidFields = true
        case .fullyValid: break
        }

        let expirationMonth: String
        let expirationTwoDigitYear: String
        let expirationValidity: CreditAndDebitCards.Validity
        let expirationDate = (rawExpirationDate ?? "").removeCharacters(characterSet: .whitespaces)
        let expirationComponents = expirationDate.components(separatedBy: "/")
        let calendar = Calendar(identifier: .iso8601)
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        switch expirationComponents.count {
        case 1:
            if let parsedMonth = parseAsExpirationMonth(slashlessString: expirationDate) {
                expirationMonth = parsedMonth
                expirationTwoDigitYear = String(expirationDate.suffix(from: expirationMonth.endIndex))
                expirationValidity = CreditAndDebitCards.validity(
                    ofExpirationMonth: expirationMonth,
                    andYear: expirationTwoDigitYear,
                    currentMonth: currentMonth,
                    currentYear: currentYear
                )
            } else {
                expirationMonth = ""
                expirationTwoDigitYear = ""
                expirationValidity = .invalid
            }
        case 2:
            expirationMonth = expirationComponents[0]
            expirationTwoDigitYear = expirationComponents[1]
            expirationValidity = CreditAndDebitCards.validity(
                ofExpirationMonth: expirationMonth,
                andYear: expirationTwoDigitYear,
                currentMonth: currentMonth,
                currentYear: currentYear
            )
        default:
            expirationMonth = ""
            expirationTwoDigitYear = ""
            expirationValidity = .invalid
        }
        switch expirationValidity {
        case .invalid: invalidFields.insert(.expirationDate)
        case .potentiallyValid: hasPotentiallyValidFields = true
        case .fullyValid: break
        }

        let cvv = (rawCvv ?? "").trimmingCharacters(in: .whitespaces)
        let cvvValidity = CreditAndDebitCards.validity(
            ofCvv: cvv,
            cardType: CreditAndDebitCards.cardType(ofNumber: numberForValidation)
        )
        switch cvvValidity {
        case .invalid: invalidFields.insert(.cvv)
        case .potentiallyValid: hasPotentiallyValidFields = true
        case .fullyValid: break
        }

        guard invalidFields.isEmpty else {
            return .invalid(invalidFields: invalidFields)
        }

        if hasPotentiallyValidFields {
            return .potentiallyValid
        }

        return .fullyValid(creditOrDebitCard: Stripe.PaymentMethod.CreditOrDebitCard(
            cardNumber: numberForValidation,
            expirationMonth: {
                guard let result = UInt8(String(expirationMonth)) else {
                    owsFail("Couldn't convert exp. month to int, even though it should be valid")
                }
                return result
            }(),
            expirationTwoDigitYear: {
                guard let result = UInt8(String(expirationTwoDigitYear)) else {
                    owsFail("Couldn't convert exp. year to int, even though it should be valid")
                }
                return result
            }(),
            cvv: cvv
        ))
    }

    private static func parseAsExpirationMonth(slashlessString str: String) -> String? {
        switch str.count {
        case 0, 1:
            // The empty string should be untouched.
            // One-digits should be assumed to be months. Examples: 1, 9
            return str
        case 2:
            // If a valid month, assume that. Examples: 01, 09, 12.
            // Otherwise, assume later digits are years. Examples: 13, 98
            return str.isValidMonth ? str : String(str.prefix(1))
        case 3:
            // This is the tricky case.
            //
            // Some are unambiguously 1-digit months. Examples: 135 → 1/35, 987 → 9/87
            //
            // Some are unambigiously 2-digit months. Examples: 012 → 01/2
            //
            // Some are ambiguous. What should happen for 123?
            //
            // - If we choose what the user intended, we're good. For example,
            //   if the user types 123 and meant 1/23.
            // - If we choose 1/23 and the user meant 12/34, the field will
            //   briefly appear invalid as they type, but will resolve after
            //   they type another digit.
            // - If we choose 12/3 and the user meant 1/23, the field will be
            //   potentially valid and the user will not be able to submit.
            //
            // We choose the second option (123 → 12/34) because the brief
            // invalid state is okay, especially because we will format the
            // input which should make this case unlikely.
            //
            // Alternatively, we could change validation based on whether the
            // expiration date field is focused.
            return String(str.prefix(str.first == "0" ? 2 : 1))
        case 4:
            return String(str.prefix(2))
        default:
            return nil
        }
    }
}

fileprivate extension String {
    /// Is this 2-character string a valid month?
    ///
    /// Not meant for general use.
    var isValidMonth: Bool {
        guard let asInt = UInt8(self) else { return false }
        return asInt >= 1 && asInt <= 12
    }
}
