//
//  File.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/10/20.
//

import UIKit

class ComplaintController: UIViewController, UINavigationControllerDelegate {
    
    private lazy var imageLabel: UILabel = {
        let imageLabel = UILabel()
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.textColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4431372549, alpha: 1)
        imageLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        imageLabel.text = "Pollution Images"
        return imageLabel
    }()
    
    private lazy var mainImage: UIImageView = {
        let mainImage = UIImageView()
        mainImage.contentMode = .scaleToFill
        mainImage.backgroundColor = .white
        mainImage.clipsToBounds = true
        mainImage.layer.cornerRadius = 10
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        return mainImage
    }()
    
    private lazy var otherImage: UIImageView = {
        let otherImage = UIImageView()
        otherImage.contentMode = .scaleToFill
        otherImage.backgroundColor = .white
        otherImage.clipsToBounds = true
        otherImage.layer.cornerRadius = 10
        otherImage.translatesAutoresizingMaskIntoConstraints = false
        return otherImage
    }()
    
    private var hstack: UIStackView = {
        let hstack = UIStackView()
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.alignment = .center
        hstack.axis = .horizontal
        hstack.spacing = 15
        hstack.distribution = .fill
        return hstack
    }()
    
    private lazy var textLabel: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        description.textColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4431372549, alpha: 1)
        description.text = "Event Description"
        return description
    }()
    
    private lazy var describeText: UITextView = {
        let describeText = UITextView()
        describeText.isUserInteractionEnabled = true
        describeText.textColor = .lightGray
        describeText.backgroundColor = .white
        describeText.font = UIFont.systemFont(ofSize: 12)
        describeText.text = textViewPlaceholder
        describeText.backgroundColor = .white
        describeText.layer.cornerRadius = 10
        return describeText
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4431372549, alpha: 1)
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        nameLabel.text = "Full Name"
        return nameLabel
    }()
    
    private lazy var nameText: UITextField = {
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .black
        name.textAlignment = .center
        name.backgroundColor = .white
        name.layer.cornerRadius = 10
        name.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        name.autocapitalizationType = .words
        name.heightAnchor.constraint(equalToConstant: 40).isActive = true
        name.widthAnchor.constraint(equalToConstant: 200).isActive = true
        name.placeholder = "Enter Your Full Name..."
        return name
    }()
    
    private lazy var numberLabel: UILabel = {
        let number = UILabel()
        number.translatesAutoresizingMaskIntoConstraints = false
        number.textColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4431372549, alpha: 1)
        number.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        number.text = "Contact Number"
        return number
    }()
    
    private lazy var numberText: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = .black
        text.backgroundColor = .white
        text.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        text.autocapitalizationType = .none
        text.textAlignment = .center
        text.layer.cornerRadius = 10
        text.heightAnchor.constraint(equalToConstant: 40).isActive = true
        text.widthAnchor.constraint(equalToConstant: 200).isActive = true
        text.placeholder = "Enter Your Contact Number..."
        return text
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.262745098, green: 0.3960784314, blue: 0.5450980392, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        button.layer.cornerRadius = 10
        button.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.4, blue: 0.3882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return button
    }()
    
    private let imagePicker = UIImagePickerController()
    private let textViewPlaceholder = "Type Your Description of the Pollution Event..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeBackground()
        describeText.delegate = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        configureNavBarUI()
        configureComplaintUI()
        submitButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func changeBackground() {
        let background = UIImage(named: "background")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
    }
    
    func configureNavBarUI() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "Complaint"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.backward"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.badge.ellipsis"), style: .plain, target: self, action: #selector(handleCamera))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
    }
    
    @objc func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func buttonPressed() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                self.submitButton.alpha = 0.3
            } completion: { (_) in
                self.submitButton.alpha = 1
            }
        }
        
        if mainImage.image == nil || otherImage.image == nil || describeText.text == textViewPlaceholder || nameText.text == nil || numberText.text == nil {
            let alert = UIAlertController(title: "Warning", message: "All Fields Need to Be Completed for a Valid Complaint", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        mainImage.image = nil
        otherImage.image = nil
        describeText.text = textViewPlaceholder
        describeText.textColor = .lightGray
        nameText.text = nil
        numberText.text = nil
        let alert = UIAlertController(title: "Successfully Submitted", message: "Someone Will Contact You Shortly Regarding Your Submitted Complaint", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func handleCamera() {
        imagePicker.allowsEditing = false
        let alert = UIAlertController(title: "Choose Pollution Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: { (action) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func configureComplaintUI() {
        let topvStack = UIStackView()
        let middlevStack = UIStackView()
        let bottomvStack = UIStackView()
        topvStack.translatesAutoresizingMaskIntoConstraints = false
        middlevStack.translatesAutoresizingMaskIntoConstraints = false
        bottomvStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topvStack)
        view.addSubview(middlevStack)
        view.addSubview(bottomvStack)
        view.addSubview(submitButton)
        
        topvStack.alignment = .center
        topvStack.axis = .vertical
        topvStack.distribution = .fill
        topvStack.spacing = 10
        topvStack.addArrangedSubview(imageLabel)
        topvStack.addArrangedSubview(hstack)
        topvStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        topvStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        middlevStack.alignment = .center
        middlevStack.axis = .vertical
        middlevStack.spacing = 10
        middlevStack.distribution = .fill
        middlevStack.addArrangedSubview(textLabel)
        middlevStack.addArrangedSubview(describeText)
        middlevStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 350).isActive = true
        middlevStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        bottomvStack.alignment = .center
        bottomvStack.axis = .vertical
        bottomvStack.distribution = .fill
        bottomvStack.spacing = 10
        bottomvStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 550).isActive = true
        bottomvStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomvStack.addArrangedSubview(nameLabel)
        bottomvStack.addArrangedSubview(nameText)
        bottomvStack.addArrangedSubview(numberLabel)
        bottomvStack.addArrangedSubview(numberText)
        
        submitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 770).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        hstack.addArrangedSubview(mainImage)
        hstack.addArrangedSubview(otherImage)
        
        mainImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        mainImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        otherImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        otherImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        describeText.heightAnchor.constraint(equalToConstant: 140).isActive = true
        describeText.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePicker.sourceType = .camera
            DispatchQueue.main.async {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Warning", message: "You Don't Have Access to the Camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alright", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            DispatchQueue.main.async {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Warning", message: "You Don't Have Permission to Access Photo Album", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alright", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ComplaintController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            DispatchQueue.main.async {
                textView.text = nil
                textView.textColor = .black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            DispatchQueue.main.async {
                textView.text = self.textViewPlaceholder
                textView.textColor = UIColor.lightGray
            }
        }
    }
}

extension ComplaintController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.placeholder = ""
        }
    }
}

extension ComplaintController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                if self.mainImage.image == nil {
                    self.mainImage.image = pickedImage
                } else if self.otherImage.image == nil {
                    self.otherImage.image = pickedImage
                } else {
                    self.imagePicker.dismiss(animated: true, completion: nil)
                    let alert = UIAlertController(title: "Warning", message: "Only Two Images Allowed per Complaint", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Understand", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        DispatchQueue.main.async {
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}
