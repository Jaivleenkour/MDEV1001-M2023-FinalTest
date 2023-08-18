import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Building Fields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var dateBuiltTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var architectsTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var imageUrlTextField: UITextField!
    
    var building: Building?
    var buildingViewController: FirestoreCRUDViewController?
    var buildingUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let building = building {
            // Editing existing movie
            nameTextField.text = building.name
            typeTextField.text = building.type
            dateBuiltTextField.text = "\(building.dateBuilt)"
            cityTextField.text = building.city
            countryTextField.text = building.country
            architectsTextField.text = building.architects
            costTextField.text = building.cost
            descriptionTextView.text = building.description
            websiteTextField.text = building.website
            imageUrlTextField.text = building.imageURL
            
            
            let url = URL(string: building.imageURL)!
            DispatchQueue.global().async {
              // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
              DispatchQueue.main.async {
              // Create Image and Update Image View
             self.buildingImage.image = UIImage(data: data)
                 }
                }
              }

            AddEditTitleLabel.text = "Edit Building"
            UpdateButton.setTitle("Update", for: .normal)
           // self.posterImageLabel.isHidden = false
            self.buildingImage.isHidden = false
        } else {
            AddEditTitleLabel.text = "Add Building"
            UpdateButton.setTitle("Add", for: .normal)
            //self.posterImageLabel.isHidden = true
            self.buildingImage.isHidden = true
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton) {
        guard
              let name = nameTextField.text,
              let type = typeTextField.text,
              let dateBuilt = dateBuiltTextField.text,
              let city = cityTextField.text,
              let country = countryTextField.text,
              let architects = architectsTextField.text,
              let cost = costTextField.text,
              let description = descriptionTextView.text,
              let website = websiteTextField.text,


                let imageurl = imageUrlTextField.text else {
            print("Invalid data")
            return
        }

        let db = Firestore.firestore()

        if let building = building {
            // Update existing building
            guard let documentID = building.documentID else {
                print("Document ID not available.")
                return
            }

            let buildingRef = db.collection("buildings").document(documentID)
            buildingRef.updateData([
                "name": name,
                "type": type,
                "dateBuilt": dateBuilt,
                "city": city,
                "country": country,
                "description": description,
                "architects": architects,
                "cost": cost,
                "website": website,
                "imageURL": imageurl
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating building: \(error)")
                } else {
                    print("Building updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.buildingUpdateCallback?()
                    }
                }
            }
        } else {
            // Add new building
            let newBuilding     = [
                "name": name,
                "type": type,
                "dateBuilt": dateBuilt,
                "city": city,
                "country": country,
                "description": description,
                "architects": architects,
                "cost": cost,
                "website": website,
                "imageURL": imageurl
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("buildings").addDocument(data: newBuilding) { [weak self] error in
                if let error = error {
                    print("Error adding building: \(error)")
                } else {
                    if self?.imageUrlTextField.text != ""
                    {
                        let url = URL(string: self!.imageUrlTextField.text!)!
                        // Fetch Image Data
                          DispatchQueue.global().async {
                           // Fetch Image Data
                         if let data = try? Data(contentsOf: url) {
                         DispatchQueue.main.async {
                        // Create Image and Update Image View
                          self?.buildingImage.image = UIImage(data: data)
                                                  }
                                              }
                                          }
                    }
                   
                    print("Building added successfully.")
                    self?.dismiss(animated: true) {
                        self?.buildingUpdateCallback?()
                    }
                }
            }
        }
    }
}
