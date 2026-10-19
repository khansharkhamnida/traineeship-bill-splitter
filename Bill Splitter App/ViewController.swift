//
//  ViewController.swift
//  Bill Splitter App
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Math
    var currentBill: BillModel?
    var billAmount: Decimal = 0
    var isServiceChargeEnabled: Bool = false
    var isGSTEnabled: Bool = false
    var roundChoice: String = "none"
    var numberOfPeople: Int = 1
    
    //MARK: UI
    private lazy var titleLabel = UIFactory.createLabel(
        text: "Eat Split",
        style: .title1,
        textColor: .systemPink,
        alignment: .center
    )
    
    private let resultsContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    // Change this at the top under your UI marker
    private lazy var billRow: UITextField = {
        let textField = UIFactory.createTextField(
            placeholder: "Enter bill amount"
        )
        
        textField.keyboardType = .numberPad
        textField.text = "$0.00"
        textField.textAlignment = .right
        textField.delegate = self
        
        return textField
    }()
    private lazy var serviceChargeLabel = UIFactory.createLabel(text: "Service Charge (10%)", style: .body)
    private lazy var serviceChargeSwitch = UIFactory.createSwitch()
    
    private lazy var gstLabel = UIFactory.createLabel(text: "GST (9%)", style: .body)
    private lazy var gstSwitch = UIFactory.createSwitch()
    
    private lazy var peopleLabel = UIFactory.createLabel(text: "Number of People: 1", style: .body)
    private lazy var customStepper = UIFactory.createStepper(
        min: 1,
        max: 100
    ) { [weak self] value in
        guard let self = self else { return }

        self.numberOfPeople = Int(value)
        self.peopleLabel.text = "Number of People: \(self.numberOfPeople)"

        self.updateBillSummary()
    }
    
    private lazy var roundButton = UIFactory.createButton(title: "Rounding: None", style: .subheadline, backgroundColor: .systemBlue)
    private var currentStrategy: RoundingStrategy = .none {
        didSet {
            updateBillSummary()
            updateRoundingButtonMenu()
        }
    }
    
    private lazy var resetButton = UIFactory.createButton(title: "Reset", style: .subheadline, backgroundColor: .systemGray, foregroundColor: .black)
    private lazy var shareButton = UIFactory.createButton(title: "Share"
                                                          , style: .subheadline, backgroundColor: .systemRed)
    
    private lazy var overallLabel = UIFactory.createLabel(text: "Subtotal: $56.00 \n Service Charge: $5.60 \n GST: $5.04 \n Total: $66.64 \n Split Between 2: $33.58 \n Rounded up by $0.01", style: .subheadline)
    
    //MARK: Stack
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 50
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray3
        setUpUI()
        setUpLayout()
    }
    
    @objc func setUpUI(){
        overallLabel.text = "Subtotal: \(billAmount)"
        setupRoundingButtonMenu()

        // Service Charge switch action
        serviceChargeSwitch.addTarget(
            self,
            action: #selector(serviceChargeToggled),
            for: .valueChanged
        )

        // GST switch action
        gstSwitch.addTarget(
            self,
            action: #selector(gstToggled),
            for: .valueChanged
        )

        resetButton.addTarget(
            self,
            action: #selector(resetBill),
            for: .touchUpInside
        )
        
        shareButton.addTarget(
            self,
            action: #selector(shareResults),
            for: .touchUpInside
        )
        
        updateBillSummary()
    }
    
    @objc func setUpLayout(){
        
        overallLabel.translatesAutoresizingMaskIntoConstraints = false


        let serviceChargeRow = UIFactory.createHorizontalRow(views: [serviceChargeLabel, serviceChargeSwitch])
        let gstRow = UIFactory.createHorizontalRow(views: [gstLabel, gstSwitch])
        let stepperRow = UIFactory.createHorizontalRow(views: [peopleLabel, customStepper])
        let roundingRow = UIFactory.createHorizontalRow(views: [roundButton])
        let resetRow = UIFactory.createHorizontalRow(views: [resetButton, shareButton])
        
        resultsContainerView.addSubview(overallLabel)

        NSLayoutConstraint.activate([
            overallLabel.topAnchor.constraint(
                equalTo: resultsContainerView.topAnchor,
                constant: 16
            ),
            overallLabel.leadingAnchor.constraint(
                equalTo: resultsContainerView.leadingAnchor,
                constant: 16
            ),
            overallLabel.trailingAnchor.constraint(
                equalTo: resultsContainerView.trailingAnchor,
                constant: -16
            ),
            overallLabel.bottomAnchor.constraint(
                equalTo: resultsContainerView.bottomAnchor,
                constant: -16
            )
        ])
        
        resetRow.distribution = .fillEqually
        resetRow.spacing = 16
        
        stack.addArrangedSubview(titleLabel)          // Title ("Eat Split")
        stack.addArrangedSubview(billRow)
        stack.addArrangedSubview(serviceChargeRow)   // Service Charge Row
        stack.addArrangedSubview(gstRow)// GST Row
        stack.addArrangedSubview(roundingRow)
        stack.addArrangedSubview(stepperRow)         // Stepper Row
        stack.addArrangedSubview(resultsContainerView)

        stack.addArrangedSubview(resetRow)           //reset
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func setupRoundingButtonMenu() {
        roundButton.showsMenuAsPrimaryAction = true
        
        updateRoundingButtonMenu()
    }
    
    @objc private func updateRoundingButtonMenu() {
        let noneAction = UIAction(
            title: "None",
            state: currentStrategy == .none ? .on : .off
        ) { [weak self] _ in
            self?.currentStrategy = .none
        }

        let roundUpAction = UIAction(
            title: "Round Up",
            state: currentStrategy == .roundUp ? .on : .off
        ) { [weak self] _ in
            self?.currentStrategy = .roundUp
        }

        let roundNearestAction = UIAction(
            title: "To Nearest Dollar",
            state: currentStrategy == .roundToNearestDollar ? .on : .off
        ) { [weak self] _ in
            self?.currentStrategy = .roundToNearestDollar
        }

        roundButton.menu = UIMenu(
            title: "Select Rounding",
            children: [noneAction, roundUpAction, roundNearestAction]
        )

        roundButton.setTitle(
            "Rounding: \(currentStrategy.rawValue)",
            for: .normal
        )
    }
    
    @objc private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    //textfield for the billAmount
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard textField == billRow else { return true }
        
        // Get the existing digits, excluding currency symbols and decimals
        let currentText = textField.text ?? ""
        let digits = currentText.filter { $0.isNumber }
        
        // Handle deleting a digit
        let rangeStart = currentText.distance(
            from: currentText.startIndex,
            to: Range(range, in: currentText)!.lowerBound
        )
        
        let rangeEnd = currentText.distance(
            from: currentText.startIndex,
            to: Range(range, in: currentText)!.upperBound
        )
        
        let digitStart = currentText.prefix(rangeStart).filter { $0.isNumber }.count
        let digitEnd = currentText.prefix(rangeEnd).filter { $0.isNumber }.count
        
        var newDigits = digits
        newDigits.removeSubrange(
            newDigits.index(
                newDigits.startIndex,
                offsetBy: digitStart
            )..<newDigits.index(
                newDigits.startIndex,
                offsetBy: digitEnd
            )
        )
        
        // Accept numeric input only
        let addedDigits = string.filter { $0.isNumber }
        newDigits.insert(contentsOf: addedDigits, at: newDigits.index(
            newDigits.startIndex,
            offsetBy: digitStart
        ))
        
        // Prevent excessively large values
        guard newDigits.count <= 15 else { return false }
        
        let cents = Decimal(
            string: newDigits.isEmpty ? "0" : newDigits
        ) ?? 0
        
        let amount = cents / 100
        
        // Limit bill amount to $1,000.00
        guard amount <= 1000 else {
            return false
        }
        
        textField.text = currencyFormatter.string(
            from: NSDecimalNumber(decimal: amount)
        )
        
        billAmount = amount
        
        // Update your bill calculation here
        updateBillSummary()
        
        return false
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        currencyFormatter.string(
            from: NSDecimalNumber(decimal: amount)
        ) ?? "$0.00"
    }
    func updateBillSummary() {
        currentBill = BillModel(
            billAmount: billAmount,
            gstEnabled: gstSwitch.isOn,
            serviceEnabled: serviceChargeSwitch.isOn,
            serviceRate: Decimal(string: "0.10")!,
            gstRate: Decimal(string: "0.09")!,
            partySize: max(numberOfPeople, 1),
            roundingStrategy: currentStrategy,
            serviceChargeAmount: 0,
            gstAmount: 0,
            totalAmount: 0,
            displayTotal: 0,
            displayPerPerson: 0
        )

        guard let bill = currentBill else { return }

        overallLabel.text = """
        Subtotal: \(formatCurrency(bill.billAmount))
        Service Charge: \(formatCurrency(bill.serviceChargeAmount))
        GST: \(formatCurrency(bill.gstAmount))
        Total: \(formatCurrency(bill.displayTotal))
        Split Between \(bill.partySize): \(formatCurrency(bill.displayPerPerson))

        """
    }
    
    @objc private func serviceChargeToggled() {
        isServiceChargeEnabled = serviceChargeSwitch.isOn
        updateBillSummary()
    }

    @objc private func gstToggled() {
        isGSTEnabled = gstSwitch.isOn
        updateBillSummary()
    }

    @objc private func resetBill(){
        // Reset bill amount
            billAmount = 0
            billRow.text = "$0.00"

            // Reset switches
            serviceChargeSwitch.setOn(false, animated: true)
            gstSwitch.setOn(false, animated: true)
            isServiceChargeEnabled = false
            isGSTEnabled = false

            // Reset number of people
            numberOfPeople = 1
            peopleLabel.text = "Number of People: 1"

            // Reset stepper
            customStepper.value = 1

            // Reset rounding
            currentStrategy = .none

            // Refresh the bill summary
            updateBillSummary()
    }

    private func snapshotResultsCard() -> UIImage? {
        resultsContainerView.layoutIfNeeded()

        guard resultsContainerView.bounds.width > 0,
              resultsContainerView.bounds.height > 0 else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(
            bounds: resultsContainerView.bounds
        )

        return renderer.image { context in
            resultsContainerView.drawHierarchy(
                in: resultsContainerView.bounds,
                afterScreenUpdates: true
            )
        }
    }

    @objc private func shareResults() {
        guard let image = snapshotResultsCard() else {
            let alert = UIAlertController(
                title: "Unable to Share",
                message: "Please try again.",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )

            present(alert, animated: true)
            return
        }

        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        if let popover = activityController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }

        present(activityController, animated: true)
    }
}


#Preview {
    ViewController()
}
