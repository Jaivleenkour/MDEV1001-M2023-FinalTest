import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreCRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var buildings: [Building] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchBuildingsFromFirestore()
    }

    func fetchBuildingsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("buildings").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedBuildings: [Building] = []

            for document in snapshot!.documents {
                let data = document.data()

                do {
                    var building = try Firestore.Decoder().decode(Building.self, from: data)
                    building.documentID = document.documentID // Set the documentID
                    fetchedBuildings.append(building)
                } catch {
                    print("Error decoding building data: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.buildings = fetchedBuildings
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath) as! MovieTableViewCell

        let building = buildings[indexPath.row]
        cell.nameLabel?.text = building.name
        
        //For attributed texts...Highlight the separator for two fields by red colour.
        let strCountry: NSString = "Country: \(building.country) | Date Built: \(building.dateBuilt)" as NSString
        let range = (strCountry).range(of: "|")
         let attribute = NSMutableAttributedString.init(string: strCountry as String)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        
        cell.country_datebuilt_Label?.attributedText = attribute
        
        //For attributed text....Highlight the Cost label by bold font
        let strCost: NSString = "Cost: \(building.cost)" as NSString // you must set your
        let range3 = (strCost).range(of: "Cost:")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .backgroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        let attributedString = NSAttributedString(string: strCost as String, attributes: attributes)
        cell.descriptionLabel?.attributedText = attributedString
        

        
            let url = URL(string: building.imageURL)!
            DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
            DispatchQueue.main.async {
            // Create Image and Update Image View
            cell.buildingImageView.image = UIImage(data: data)
                        }
                    }
                }
        
       
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let building = buildings[indexPath.row]
            showDeleteConfirmationAlert(for: building) { confirmed in
                if confirmed {
                    self.deleteBuilding(at: indexPath)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEditSegue" {
            if let addEditVC = segue.destination as? AddEditFirestoreViewController {
                addEditVC.buildingViewController = self
                if let indexPath = sender as? IndexPath {
                    let building = buildings[indexPath.row]
                    addEditVC.building = building
                } else {
                    addEditVC.building = nil
                }

                addEditVC.buildingUpdateCallback = { [weak self] in
                    self?.fetchBuildingsFromFirestore()
                }
            }
        }
    }

    func showDeleteConfirmationAlert(for movie: Building, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Building", message: "Are you sure you want to delete this building?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteBuilding(at indexPath: IndexPath) {
        let building = buildings[indexPath.row]

        guard let documentID = building.documentID else {
            print("Invalid document ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("buildings").document(documentID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                DispatchQueue.main.async {
                    print("Building deleted successfully.")
                    self?.buildings.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
