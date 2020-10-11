//
//  FacilityResultTable.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/4/20.
//
//
import UIKit
import MapKit
import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class FacilityResultTable: UIViewController {
    
    private let reuseIdentifier = "facilityCell"
    private let popupOffset: CGFloat = 600
    public var surroundingFacility: [(FacilityItem, CLLocation, Double)]?
    public var tableView: UITableView!
    public var updateDelegate: UpdateFacilityResultTable?
    
    public var stepperStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    public var textStack: UIStackView = {
       let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    public var stepperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Change Purview"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.5552168053, green: 0.7820718719, blue: 1, alpha: 1)
        return label
    }()
    
    public var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.autorepeat = false
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        return stepper
    }()
    
    public var ftextTop: UILabel = {
        let display = UILabel()
        display.translatesAutoresizingMaskIntoConstraints = false
        display.font = UIFont.systemFont(ofSize: 15)
        display.textColor = #colorLiteral(red: 0.5552168053, green: 0.7820718719, blue: 1, alpha: 1)
        return display
    }()
    
    public var ftextBottom: UILabel = {
        let display = UILabel()
        display.translatesAutoresizingMaskIntoConstraints = false
        display.font = UIFont.systemFont(ofSize: 15)
        display.textColor = #colorLiteral(red: 0.5552168053, green: 0.7820718719, blue: 1, alpha: 1)
        return display
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Facility"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.5552168053, green: 0.7820718719, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Facility"
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        label.textColor = #colorLiteral(red: 0.5552168053, green: 0.7820718719, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureHeader()
        layout()
        stepper.addTarget(self, action: #selector(stepperPressed), for: .valueChanged)
        tableView.reloadData()
        popupView.addGestureRecognizer(panRecognizer)
    }


    private var bottomConstraint = NSLayoutConstraint()

    private func configureHeader() {
        popupView.addSubview(textStack)
        popupView.addSubview(stepperStack)
        stepperStack.addArrangedSubview(stepperLabel)
        stepperStack.addArrangedSubview(stepper)
        textStack.addArrangedSubview(ftextTop)
        textStack.addArrangedSubview(ftextBottom)
        stepperStack.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -22).isActive = true
        stepperStack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        textStack.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 28).isActive = true
        textStack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 22).isActive = true
    }
    
    @objc func stepperPressed() {
        let facilityNum = surroundingFacility?.count ?? 0
        ftextTop.text = stepper.value == 1.0 ? "\(Int(stepper.value)) mile away" : "\(Int(stepper.value)) miles away"
        ftextBottom.text = facilityNum == 0 ? "\(facilityNum) facility" : "\(facilityNum) facilities"
        updateDelegate?.updateResultTable()
    }
    
    private func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.dragInteractionEnabled = true
        popupView.addSubview(tableView)
        
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 70).isActive = true
        tableView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
    }
    
    private func layout() {
        
        view.addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 750).isActive = true

        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true

        popupView.addSubview(openTitleLabel)
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30).isActive = true
    }

    private var currentState: State = .closed

    private var runningAnimators = [UIViewPropertyAnimator]()

    private var animationProgress = [CGFloat]()

    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()

    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {

        guard runningAnimators.isEmpty else {return}

        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
            }
            self.view.layoutIfNeeded()
        }

        transitionAnimator.addCompletion { (position) in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                fatalError()
            }

            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            self.runningAnimators.removeAll()
        }

        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            switch state {
            case .open:
                self.openTitleLabel.alpha = 1
            case .closed:
                self.closedTitleLabel.alpha = 1
            }
        }
        inTitleAnimator.scrubsLinearly = false

        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            switch state {
            case .open:
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.openTitleLabel.alpha = 0
            }
        }
        outTitleAnimator.scrubsLinearly = false

        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()

        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)

    }

    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset

            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
        case .ended:
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0

            if yVelocity == 0 {
                runningAnimators.forEach {$0.continueAnimation(withTimingParameters: nil, durationFactor: 0)}
                break
            }
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            ()
        }
    }
}

extension FacilityResultTable: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let facilityNum = surroundingFacility?.count ?? 0
        ftextTop.text = stepper.value == 1.0 ? "\(Int(stepper.value)) mile away" : "\(Int(stepper.value)) miles away"
        ftextBottom.text = facilityNum == 0 ? "\(facilityNum) facility" : "\(facilityNum) facilities"
        return facilityNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let surroundingFacility = surroundingFacility {
            let selectedFacility = surroundingFacility[indexPath.row].0
            cell.textLabel?.text = selectedFacility.facilityName
            var detailedText = "\(selectedFacility.streetAddress ?? ""), \(selectedFacility.city ?? "")"
            if detailedText.count > 30 {
                detailedText = "\((detailedText as NSString).substring(to: 30))..."
            }
            cell.detailTextLabel?.text = detailedText
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
