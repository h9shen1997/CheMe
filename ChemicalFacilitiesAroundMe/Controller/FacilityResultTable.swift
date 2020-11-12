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
import CoreData

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
    var surroundingFacility: [(FacilityItem, CLLocation, Double)]?
    var tableView: UITableView!
    var locationArray = [CLLocation]()
    var updateDelegate: UpdateFacilityResultTable?
    var stepperValue = 1
    
    public var stepperStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    public var addButton: UIButton = {
        let add = UIButton()
        add.translatesAutoresizingMaskIntoConstraints = false
        add.setImage(UIImage(named: "add"), for: .normal)
        add.tag = 1
        add.heightAnchor.constraint(equalToConstant: 23).isActive = true
        add.widthAnchor.constraint(equalToConstant: 23).isActive = true
        add.addTarget(self, action: #selector(stepperPressed), for: .touchUpInside)
        return add
    }()
    
    public var minusButton: UIButton = {
        let minus = UIButton()
        minus.translatesAutoresizingMaskIntoConstraints = false
        minus.setImage(UIImage(named: "minus"), for: .normal)
        minus.tag = 0
        minus.heightAnchor.constraint(equalToConstant: 23).isActive = true
        minus.widthAnchor.constraint(equalToConstant: 23).isActive = true
        minus.addTarget(self, action: #selector(stepperPressed), for: .touchUpInside)
        return minus
    }()
    
    public var hstack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.spacing = 5
        stack.axis = .horizontal
        return stack
    }()
    
    public var textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 7
        return stack
    }()
    
    public var stepperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Change Purview"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.7215686275, green: 0.231372549, blue: 0.368627451, alpha: 1)
        return label
    }()
    
    public var ftextTop: UILabel = {
        let display = UILabel()
        display.translatesAutoresizingMaskIntoConstraints = false
        display.font = UIFont.systemFont(ofSize: 14)
        display.textColor = #colorLiteral(red: 0.7215686275, green: 0.231372549, blue: 0.368627451, alpha: 1)
        return display
    }()
    
    public var ftextBottom: UILabel = {
        let display = UILabel()
        display.translatesAutoresizingMaskIntoConstraints = false
        display.font = UIFont.systemFont(ofSize: 14)
        display.textColor = #colorLiteral(red: 0.7215686275, green: 0.231372549, blue: 0.368627451, alpha: 1)
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.7215686275, green: 0.231372549, blue: 0.368627451, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Facility"
        label.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        label.textColor = #colorLiteral(red: 0.7215686275, green: 0.231372549, blue: 0.368627451, alpha: 1)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.backgroundColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4941176471, alpha: 1)
        configureTableView()
        configureHeader()
        layout()
        tableView.reloadData()
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func configureHeader() {
        popupView.addSubview(textStack)
        popupView.addSubview(stepperStack)
        stepperStack.addArrangedSubview(stepperLabel)
        minusButton.layer.cornerRadius = 30
        addButton.layer.cornerRadius = 30
        hstack.addArrangedSubview(minusButton)
        hstack.addArrangedSubview(addButton)
        stepperStack.addArrangedSubview(hstack)
        textStack.addArrangedSubview(ftextTop)
        textStack.addArrangedSubview(ftextBottom)
        stepperStack.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -22).isActive = true
        stepperStack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 22).isActive = true
        textStack.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 28).isActive = true
        textStack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 22).isActive = true
    }
    
    @objc func stepperPressed(_ sender: UIButton!) {
        let facilityNum = surroundingFacility?.count ?? 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                sender.alpha = 0.5
            } completion: { (_) in
                sender.alpha = 1
            }
        }
        switch sender.tag {
        case 0:
            if stepperValue == 1 {
                let alert = UIAlertController(title: "Notice", message: "Minimum Purview Is 1 Mile", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                stepperValue -= 1
            }
        case 1:
            if stepperValue == 5 {
                let alert = UIAlertController(title: "Notice", message: "Maximum Purview Is 5 Miles", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                stepperValue += 1
            }
        default:
            fatalError()
        }
        DispatchQueue.main.async {
            self.ftextTop.text = self.stepperValue == 1 ? "\(self.stepperValue) Mile Away" : "\(self.stepperValue) Miles Away"
            self.ftextBottom.text = facilityNum == 0 ? "\(facilityNum) Facility" : "\(facilityNum) Facilities"
            self.updateDelegate?.updateResultTable()
        }
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
        tableView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 80).isActive = true
        tableView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        
        let footer = UIView()
        footer.backgroundColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4941176471, alpha: 1)
        tableView.tableFooterView = footer
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        tableView.tableHeaderView = line
        line.backgroundColor = tableView.separatorColor
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
                self.popupView.layer.cornerRadius = 10
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
        DispatchQueue.main.async {
            self.ftextTop.text = self.stepperValue == 1 ? "\(self.stepperValue) mile away" : "\(self.stepperValue) miles away"
            self.ftextBottom.text = facilityNum == 0 ? "\(facilityNum) facility" : "\(facilityNum) facilities"
        }
        return facilityNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        //locationArray.removeAll()
        if let surroundingFacility = surroundingFacility {
            locationArray.append(surroundingFacility[indexPath.row].1)
            let selectedFacility = surroundingFacility[indexPath.row].0
            var detailedText = "\(selectedFacility.address ?? ""), \(selectedFacility.city ?? "")"
            if detailedText.count > 30 {
                detailedText = "\((detailedText as NSString).substring(to: 31))..."
            }
            cell.textLabel?.text = selectedFacility.facilityName
            cell.detailTextLabel?.text = detailedText
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let facilityController = FacilityController()
        let navigationController = UINavigationController(rootViewController: facilityController)
        navigationController.modalPresentationStyle = .fullScreen
        facilityController.modalPresentationStyle = .fullScreen
        tableView.deselectRow(at: indexPath, animated: true)
        let currentCell = tableView.cellForRow(at: indexPath)
        let facilityName = currentCell?.textLabel?.text
        let location = surroundingFacility?[indexPath.row].1
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let classification = surroundingFacility?[indexPath.row].0.classification
        let facilityDesc = surroundingFacility?[indexPath.row].0.facilityDescription
        facilityController.facilityName = facilityName
        facilityController.latitude = latitude
        facilityController.longitude = longitude
        facilityController.classificationString = classification!
        facilityController.facilityDescString = facilityDesc!
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .flipHorizontal
        facilityController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
