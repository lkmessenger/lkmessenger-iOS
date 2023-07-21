//
// Copyright 2022 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging

class CreditOrDebitCardDonationViewController: OWSTableViewController2 {
    let donationAmount: FiatMoney
    let donationMode: DonationMode
    let onFinished: () -> Void

    init(
        donationAmount: FiatMoney,
        donationMode: DonationMode,
        onFinished: @escaping () -> Void
    ) {
        owsAssert(FeatureFlags.canDonateWithCard)

        self.donationAmount = donationAmount
        self.donationMode = donationMode
        self.onFinished = onFinished

        super.init()
    }

    // MARK: - View callbacks

    public override func viewDidLoad() {
        shouldAvoidKeyboard = true

        super.viewDidLoad()

        render()

        contents = OWSTableContents(sections: [
            donationAmountSection,
            cardNumberSection,
            expirationDateSection,
            cvvSection,
            submitButtonSection
        ])
    }

    // MARK: - Events

    @objc
    private func didTextFieldChange() {
        render()
    }

    private func didSubmit() {
        switch formState {
        case .invalid, .potentiallyValid:
            owsFail("It should be impossible to submit the form without a fully-valid card. Is the submit button properly disabled?")
        case let .fullyValid(creditOrDebitCard):
            switch donationMode {
            case .oneTime:
                oneTimeDonation(with: creditOrDebitCard)
            case let .monthly(
                subscriptionLevel,
                subscriberID,
                _,
                currentSubscriptionLevel
            ):
                monthlyDonation(
                    with: creditOrDebitCard,
                    newSubscriptionLevel: subscriptionLevel,
                    priorSubscriptionLevel: currentSubscriptionLevel,
                    subscriberID: subscriberID
                )
            }
        }
    }

    func didFailDonation(error: Error) {
        DonationViewsUtil.presentDonationErrorSheet(
            from: self,
            error: error,
            currentSubscription: {
                switch donationMode {
                case .oneTime: return nil
                case let .monthly(_, _, currentSubscription, _): return currentSubscription
                }
            }()
        )
    }

    // MARK: - Rendering

    private func render() {
        // Only change the placeholder when enough digits are entered.
        // Helps avoid a jittery UI as you type/delete.
        let rawNumber = cardNumberTextField.text ?? ""
        if rawNumber.count >= 2 {
            let cardType = CreditAndDebitCards.cardType(ofNumber: rawNumber)
            cvvTextField.placeholder = String("1234".prefix(cardType.cvvCount))
        }

        switch formState {
        case .invalid, .potentiallyValid:
            submitButton.isEnabled = false
        case .fullyValid:
            submitButton.isEnabled = true
        }
    }

    // MARK: - Donation amount section

    private lazy var donationAmountSection: OWSTableSection = {
        let result = OWSTableSection(
            items: [.init(
                customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    cell.selectionStyle = .none

                    guard let self else { return cell }

                    func label() -> UILabel {
                        let result = UILabel()
                        result.textAlignment = .center
                        result.numberOfLines = 0
                        result.lineBreakMode = .byWordWrapping
                        return result
                    }

                    let headerLabel = label()
                    headerLabel.text = {
                        let amountString = DonationUtilities.format(money: self.donationAmount)
                        let format = NSLocalizedString(
                            "CARD_DONATION_HEADER",
                            comment: "Users can donate to Link Messenger with a credit or debit card. This is the heading on that screen, telling them how much they'll donate. Embeds {{formatted amount of money}}, such as \"$20\"."
                        )
                        return String(format: format, amountString)
                    }()
                    headerLabel.font = .ows_dynamicTypeTitle3.ows_semibold

                    let instructionsLabel = label()
                    instructionsLabel.text = NSLocalizedString(
                        "CARD_DONATION_INSTRUCTIONS",
                        comment: "Users can donate to Link Messenger with a credit or debit card. These are instructions on that screen, asking users to enter their payment card info."
                    )
                    instructionsLabel.font = .ows_dynamicTypeBody
                    instructionsLabel.textColor = Theme.secondaryTextAndIconColor

                    let stackView = UIStackView(arrangedSubviews: [
                        headerLabel,
                        instructionsLabel
                    ])
                    cell.contentView.addSubview(stackView)
                    stackView.axis = .vertical
                    stackView.spacing = 4
                    stackView.autoPinEdgesToSuperviewMargins()

                    return cell
                }
            )]
        )
        result.hasBackground = false
        return result
    }()

    // MARK: - Card form

    private func textField() -> UITextField {
        let result = OWSTextField()

        result.font = .ows_dynamicTypeBodyClamped
        result.textColor = Theme.primaryTextColor
        result.autocorrectionType = .no
        result.spellCheckingType = .no
        result.keyboardType = .numberPad
        result.textContentType = .creditCardNumber

        result.delegate = self
        result.addTarget(self, action: #selector(didTextFieldChange), for: .allEditingEvents)

        return result
    }

    private var formState: FormState {
        Self.formState(
            cardNumber: cardNumberTextField.text,
            isCardNumberFieldFocused: cardNumberTextField.isFirstResponder,
            expirationDate: expirationDateTextField.text,
            cvv: cvvTextField.text
        )
    }

    // MARK: Card number

    private lazy var cardNumberTextField: UITextField = {
        let result = textField()
        result.returnKeyType = .next
        result.placeholder = "0000 0000 0000 0000"
        result.accessibilityIdentifier = "card_number_textfield"
        return result
    }()

    private lazy var cardNumberSection: OWSTableSection = {
        OWSTableSection(
            title: NSLocalizedString(
                "CARD_DONATION_CARD_NUMBER_LABEL",
                comment: "Users can donate to Link Messenger with a credit or debit card. This is the label for the card number field on that screen."
            ),
            items: [.init(
                customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    cell.selectionStyle = .none

                    guard let self else { return cell }

                    cell.contentView.addSubview(self.cardNumberTextField)
                    self.cardNumberTextField.autoPinEdgesToSuperviewMargins()

                    return cell
                },
                actionBlock: { [weak self] in
                    self?.cardNumberTextField.becomeFirstResponder()
                }
            )]
        )
    }()

    // MARK: Expiration date

    private lazy var expirationDateTextField: UITextField = {
        let result = textField()
        result.returnKeyType = .next
        result.placeholder = NSLocalizedString(
            "CARD_DONATION_EXPIRATION_DATE_PLACEHOLDER",
            comment: "Users can donate to Link Messenger with a credit or debit card. This is the label for the card expiration date field on that screen."
        )
        result.accessibilityIdentifier = "expiration_date_textfield"
        return result
    }()

    private lazy var expirationDateSection: OWSTableSection = {
        OWSTableSection(
            title: NSLocalizedString(
                "CARD_DONATION_EXPIRATION_DATE_LABEL",
                comment: "Users can donate to Link Messenger with a credit or debit card. This is the label for the expiration date field on that screen. Try to use a short string to make space in the UI. (For example, the English text uses \"Exp. Date\" instead of \"Expiration Date\")."
            ),
            items: [.init(
                customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    cell.selectionStyle = .none

                    guard let self else { return cell }

                    cell.contentView.addSubview(self.expirationDateTextField)
                    self.expirationDateTextField.autoPinEdgesToSuperviewMargins()

                    return cell
                },
                actionBlock: { [weak self] in
                    self?.expirationDateTextField.becomeFirstResponder()
                }
            )]
        )
    }()

    // MARK: CVV

    private lazy var cvvTextField: UITextField = {
        let result = textField()
        result.returnKeyType = .done
        result.placeholder = "123"
        result.accessibilityIdentifier = "cvv_textfield"
        return result
    }()

    private lazy var cvvSection: OWSTableSection = {
        OWSTableSection(
            title: NSLocalizedString(
                "CARD_DONATION_CVV_LABEL",
                comment: "Users can donate to Link Messenger with a credit or debit card. This is the label for the card verification code (CVV) field on that screen."
            ),
            items: [.init(
                customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    cell.selectionStyle = .none

                    guard let self else { return cell }

                    cell.contentView.addSubview(self.cvvTextField)
                    self.cvvTextField.autoPinEdgesToSuperviewMargins()

                    return cell
                },
                actionBlock: { [weak self] in
                    self?.cvvTextField.becomeFirstResponder()
                }
            )]
        )
    }()

    // MARK: - Submit button

    private lazy var submitButton: OWSButton = {
        let title = NSLocalizedString(
            "CARD_DONATION_DONATE_BUTTON",
            comment: "Users can donate to Link Messenger with a credit or debit card. This is the text on the \"Donate\" button."
        )
        let result = OWSButton(title: title) { [weak self] in
            self?.didSubmit()
        }
        result.dimsWhenHighlighted = true
        result.dimsWhenDisabled = true
        result.layer.cornerRadius = 8
        result.backgroundColor = .ows_accentBlue
        result.titleLabel?.font = .ows_dynamicTypeBody.ows_semibold
        return result
    }()

    private lazy var submitButtonSection: OWSTableSection = {
        let result = OWSTableSection(items: [.init(
            customCellBlock: { [weak self] in
                let cell = OWSTableItem.newCell()
                cell.selectionStyle = .none
                guard let self else { return cell }

                cell.contentView.addSubview(self.submitButton)
                self.submitButton.autoPinWidthToSuperviewMargins()
                return cell
            }
        )])

        // TODO(donations) Remove or replace this text
        result.footerTitle = "NOTE: This screen is incomplete and is only enabled for internal users."

        result.hasBackground = false
        return result
    }()
}

// MARK: - UITextViewDelegate

extension CreditOrDebitCardDonationViewController: UITextFieldDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        text.isAsciiDigitsOnly
    }
}
