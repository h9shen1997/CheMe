//
//  FacilityController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/11/20.
//

import UIKit
import GooglePlaces
import SafariServices

class FacilityController: UIViewController {
    
    var placesClient = GMSPlacesClient()
    var imageView: UIImageView!
    var sideImageViewTop: UIImageView!
    var sideImageViewMiddle: UIImageView!
    var sideImageViewBottom: UIImageView!
    var latitude: Double!
    var longitude: Double!
    var facilityName: String!
    var name: UITextView!
    var address: UITextView!
    var classification: UITextView!
    var facilityDesc: UITextView!
    var facilityDescString: String!
    var classificationString: String!
    var learnButton: UIButton!
    var webButton: UIButton!
    var url: URL?
    
    
    var lblText: UITextView!
    let placeURL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=AIzaSyDltyRQPHZu7R-K86F65vj-N1YaW7p3YB8&&inputtype=textquery&fields=formatted_address,name,place_id&input="
    let locationBiasURL = "&locationbias=circle:1000@"
    var facility: FacilityModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nameArray = facilityName.components(separatedBy: " ")
        let facilitySearchText = "\((nameArray[0]).lowercased())%20\((nameArray[1]).lowercased())"
        fetchSearch(input: facilitySearchText, latitude: latitude, longitude: longitude)
        
        configureNavBarUI()
        configureMainImageView()
        configureSideImageView()
        configureUI()
        configureButton()
        classification.delegate = self
        facilityDesc.delegate = self
        name.delegate = self
        address.delegate = self
    }
    
    func fetchSearch(input: String, latitude: Double, longitude: Double) {
        let finalURL = "\(placeURL)\(input)\(locationBiasURL)\(String(latitude)),\(String(longitude))"
        print(finalURL)
        performRequest(with: finalURL)
    }
    
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    return
                }
                if let safeData = data {
                    self.facility = self.parseIDJson(safeData)
                    if let facility = self.facility {
                        DispatchQueue.main.async {
                            self.getPlaceDetail(with: facility.place_id)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseIDJson(_ facilityData: Data) -> FacilityModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FacilityData.self, from: facilityData)
            let status = decodedData.status
            let formatted_address = decodedData.candidates[0].formatted_address
            let name = decodedData.candidates[0].name
            let place_id = decodedData.candidates[0].place_id
            let facility = FacilityModel(facilityName: name, address: formatted_address, place_id: place_id, status: status)
            return facility
        } catch {
            return nil
        }
    }
    
    func configureNavBarUI() {
        view.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "Facility Info"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "delete.left"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone.circle"), style: .plain, target: self, action: #selector(handleContact))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
    }
    
    func configureMainImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.tag = 0
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 260).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        imageView.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
    }
    
    func configureSideImageView() {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 10
        
        sideImageViewTop = UIImageView()
        sideImageViewMiddle = UIImageView()
        sideImageViewBottom = UIImageView()
        sideImageViewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        sideImageViewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        sideImageViewBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        sideImageViewTop.translatesAutoresizingMaskIntoConstraints = false
        sideImageViewMiddle.translatesAutoresizingMaskIntoConstraints = false
        sideImageViewBottom.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(sideImageViewTop)
        stack.addArrangedSubview(sideImageViewMiddle)
        stack.addArrangedSubview(sideImageViewBottom)
        sideImageViewTop.isUserInteractionEnabled = true
        sideImageViewMiddle.isUserInteractionEnabled = true
        sideImageViewBottom.isUserInteractionEnabled = true
        sideImageViewTop.tag = 1
        sideImageViewTop.layer.cornerRadius = 5
        sideImageViewTop.contentMode = .scaleAspectFill
        sideImageViewTop.clipsToBounds = true
        sideImageViewTop.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        sideImageViewTop.heightAnchor.constraint(equalToConstant: 80).isActive = true
        sideImageViewTop.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sideImageViewMiddle.tag = 2
        sideImageViewMiddle.layer.cornerRadius = 5
        sideImageViewMiddle.contentMode = .scaleAspectFill
        sideImageViewMiddle.clipsToBounds = true
        sideImageViewMiddle.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        sideImageViewMiddle.heightAnchor.constraint(equalToConstant: 80).isActive = true
        sideImageViewMiddle.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sideImageViewBottom.tag = 3
        sideImageViewBottom.layer.cornerRadius = 5
        sideImageViewBottom.contentMode = .scaleAspectFill
        sideImageViewBottom.clipsToBounds = true
        sideImageViewBottom.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        sideImageViewBottom.heightAnchor.constraint(equalToConstant: 80).isActive = true
        sideImageViewBottom.widthAnchor.constraint(equalToConstant: 80).isActive = true
        stack.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        stack.widthAnchor.constraint(equalToConstant: 80).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 260).isActive = true
    }
    
    func configureUI() {
        let stackone = UIStackView()
        let stacktwo = UIStackView()
        let stackthree = UIStackView()
        let stackfour = UIStackView()
        let stackall = UIStackView()
        view.addSubview(stackall)
        
        stackall.addArrangedSubview(stackone)
        stackall.addArrangedSubview(stacktwo)
        stackall.addArrangedSubview(stackthree)
        stackall.addArrangedSubview(stackfour)
        stackall.alignment = .center
        stackall.axis = .vertical
        stackall.spacing = 5
        stackall.distribution = .fill
        stackall.translatesAutoresizingMaskIntoConstraints = false
        stackall.topAnchor.constraint(equalTo: view.topAnchor, constant: 380).isActive = true

        stackone.alignment = .center
        stackone.spacing = 5
        stackone.axis = .vertical
        stackone.distribution = .fill
        stackone.translatesAutoresizingMaskIntoConstraints = false
        
        stacktwo.alignment = .center
        stacktwo.spacing = 5
        stacktwo.axis = .vertical
        stacktwo.distribution = .fill
        stacktwo.translatesAutoresizingMaskIntoConstraints = false
        
        stackthree.alignment = .center
        stackthree.spacing = 5
        stackthree.axis = .vertical
        stackthree.distribution = .fill
        stackthree.translatesAutoresizingMaskIntoConstraints = false
        
        stackfour.alignment = .center
        stackfour.spacing = 5
        stackfour.axis = .vertical
        stackfour.distribution = .fill
        stackfour.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = #colorLiteral(red: 0.262745098, green: 0.3960784314, blue: 0.5450980392, alpha: 1)
        
        name = UITextView()
        view.addSubview(name)
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        name.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        name.text = "N/A"
        name.isUserInteractionEnabled = false
        name.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        name.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        name.heightAnchor.constraint(equalToConstant: 35).isActive = true
        name.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        stackone.addArrangedSubview(nameLabel)
        stackone.addArrangedSubview(name)
        
        let addressLabel = UILabel()
        view.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = "Address"
        addressLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        addressLabel.textColor = #colorLiteral(red: 0.262745098, green: 0.3960784314, blue: 0.5450980392, alpha: 1)
        
        address = UITextView()
        view.addSubview(address)
        address.translatesAutoresizingMaskIntoConstraints = false
        address.textAlignment = .center
        address.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        address.text = "N/A"
        address.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        address.isUserInteractionEnabled = false
        address.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        address.heightAnchor.constraint(equalToConstant: 50).isActive = true
        address.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        stacktwo.addArrangedSubview(addressLabel)
        stacktwo.addArrangedSubview(address)
        
        let classLabel = UILabel()
        view.addSubview(classLabel)
        classLabel.translatesAutoresizingMaskIntoConstraints = false
        classLabel.text = "Classification"
        classLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        classLabel.textColor = #colorLiteral(red: 0.262745098, green: 0.3960784314, blue: 0.5450980392, alpha: 1)
        
        classification = UITextView()
        view.addSubview(classification)
        classification.translatesAutoresizingMaskIntoConstraints = false
        classification.textAlignment = .center
        classification.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        classification.text = "N/A"
        classification.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        classification.isUserInteractionEnabled = false
        classification.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        classification.heightAnchor.constraint(equalToConstant: 35).isActive = true
        classification.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        stackthree.addArrangedSubview(classLabel)
        stackthree.addArrangedSubview(classification)
        
        let descLabel = UILabel()
        view.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.text = "Description"
        descLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        descLabel.textColor = #colorLiteral(red: 0.262745098, green: 0.3960784314, blue: 0.5450980392, alpha: 1)
        
        facilityDesc = UITextView()
        view.addSubview(facilityDesc)
        facilityDesc.translatesAutoresizingMaskIntoConstraints = false
        facilityDesc.textAlignment = .center
        facilityDesc.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        facilityDesc.text = "N/A"
        facilityDesc.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        facilityDesc.isUserInteractionEnabled = false
        facilityDesc.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        facilityDesc.heightAnchor.constraint(equalToConstant: 35).isActive = true
        facilityDesc.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        stackfour.addArrangedSubview(descLabel)
        stackfour.addArrangedSubview(facilityDesc)
        
        stackall.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureButton() {
        learnButton = UIButton(type: .custom)
        learnButton.translatesAutoresizingMaskIntoConstraints = false
        learnButton.setImage(UIImage(named: "learn"), for: .normal)
        learnButton.translatesAutoresizingMaskIntoConstraints = false
        learnButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        learnButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        learnButton.addTarget(self, action: #selector(learnButtonPressed), for: .touchUpInside)
        
        webButton = UIButton(type: .custom)
        webButton.translatesAutoresizingMaskIntoConstraints = false
        webButton.setImage(UIImage(named: "website"), for: .normal)
        webButton.translatesAutoresizingMaskIntoConstraints = false
        webButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        webButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        webButton.addTarget(self, action: #selector(webButtonPressed), for: .touchUpInside)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .fill
        buttonStack.spacing = 60
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(learnButton)
        buttonStack.addArrangedSubview(webButton)
        buttonStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 700).isActive = true
        buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let learnText = UILabel()
        view.addSubview(learnText)
        learnText.translatesAutoresizingMaskIntoConstraints = false
        learnText.text = "Learn"
        learnText.contentMode = .center
        learnText.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        learnText.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        learnText.topAnchor.constraint(equalTo: view.topAnchor, constant: 760).isActive = true
        learnText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 135).isActive = true
        learnText.heightAnchor.constraint(equalToConstant: 20).isActive = true
        learnText.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        let webText = UILabel()
        view.addSubview(webText)
        webText.translatesAutoresizingMaskIntoConstraints = false
        webText.text = "Website"
        webText.contentMode = .center
        webText.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        webText.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        webText.topAnchor.constraint(equalTo: view.topAnchor, constant: 760).isActive = true
        webText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 237).isActive = true
        webText.heightAnchor.constraint(equalToConstant: 20).isActive = true
        webText.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    @objc func learnButtonPressed() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                self.learnButton.alpha = 0.3
            } completion: { (_) in
                self.learnButton.alpha = 1
            }
        }
    }
    
    @objc func webButtonPressed() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                self.webButton.alpha = 0.3
            } completion: { (_) in
                self.webButton.alpha = 1
            }
        }
        if let url = url {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            let vc = SFSafariViewController(url: url, configuration: config)
            DispatchQueue.main.async {
                self.present(vc, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Warning", message: "This facility currently does not have a website", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func imageTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.view?.tag == 1 && sideImageViewTop.image != nil {
            let temp = sideImageViewTop.image
            sideImageViewTop.image = imageView.image
            imageView.image = temp
        }
        if recognizer.view?.tag == 2 && sideImageViewMiddle.image != nil {
            let temp = sideImageViewMiddle.image
            sideImageViewMiddle.image = imageView.image
            imageView.image = temp
        }
        if recognizer.view?.tag == 3 && sideImageViewBottom.image != nil {
            let temp = sideImageViewBottom.image
            sideImageViewBottom.image = imageView.image
            imageView.image = temp
        }
    }
    
    @objc func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleContact() {
        
    }
    
    func getPlaceDetail(with placeID: String) {
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.phoneNumber.rawValue) | UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.website.rawValue))!
        
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                // Get the metadata for the first photo in the place photo metadata list.
                if let name = place.name {
                    self.name.text = name
                }
                if let address = place.formattedAddress {
                    self.address.text = address
                }
                if let url = place.website {
                    self.url = url
                }
                self.classification.text = self.classificationString
                self.facilityDesc.text = self.facilityDescString
                let photoArray: [GMSPlacePhotoMetadata]? = place.photos
                if let photoArray = photoArray {
                    if photoArray.count > 0 {
                        let photoMetadata = photoArray[0]
                        self.placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                            if let error = error {
                                // TODO: Handle the error.
                                print("Error loading photo metadata: \(error.localizedDescription)")
                                return
                            } else {
                                // Display the first image and its attributions.
                                self.imageView?.image = photo;
                                //self.lblText?.attributedText = photoMetadata.attributions;
                            }
                        })
                    }
                    if photoArray.count > 1 {
                        let sideTopPhotoMetadata : GMSPlacePhotoMetadata = place.photos![1]
                        self.placesClient.loadPlacePhoto(sideTopPhotoMetadata, callback: { (photo, error) -> Void in
                            if let error = error {
                                // TODO: Handle the error.
                                print("Error loading photo metadata: \(error.localizedDescription)")
                                return
                            } else {
                                // Display the first image and its attributions.
                                self.sideImageViewTop?.image = photo;
                                //self.lblText?.attributedText = photoMetadata.attributions;
                            }
                        })
                    }
                    if photoArray.count > 2 {
                        let sideMiddlePhotoMetadata : GMSPlacePhotoMetadata = place.photos![2]
                        self.placesClient.loadPlacePhoto(sideMiddlePhotoMetadata, callback: { (photo, error) -> Void in
                            if let error = error {
                                // TODO: Handle the error.
                                print("Error loading photo metadata: \(error.localizedDescription)")
                                return
                            } else {
                                // Display the first image and its attributions.
                                self.sideImageViewMiddle?.image = photo;
                                //self.lblText?.attributedText = photoMetadata.attributions;
                            }
                        })
                    }
                    if photoArray.count > 3 {
                        let sideBottomPhotoMetadata : GMSPlacePhotoMetadata = place.photos![3]
                        self.placesClient.loadPlacePhoto(sideBottomPhotoMetadata, callback: { (photo, error) -> Void in
                            if let error = error {
                                // TODO: Handle the error.
                                print("Error loading photo metadata: \(error.localizedDescription)")
                                return
                            } else {
                                // Display the first image and its attributions.
                                self.sideImageViewBottom?.image = photo;
                                //self.lblText?.attributedText = photoMetadata.attributions;
                            }
                        })
                    }
                }
            }
        })
    }
}

extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension FacilityController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.centerVerticalText()
    }
}
