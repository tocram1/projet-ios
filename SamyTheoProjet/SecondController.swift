//
//  SecondController.swift
//  SamyTheoProjet
//
//  Created by etudiant on 21/09/2022.
//

import Foundation
import UIKit
import FirebaseCore

class SecondController: UIViewController {
    
    var data = [Product]()
    @IBOutlet weak var tableCell: UITableView!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableCell.dataSource = self
        // Do any additional setup after loading the view.
    }

    func fetchingApiData(URL url:URL, completion: @escaping ([Product])-> Void) {
        let task = URLSession.shared.dataTask(with: url ) {( data, response, error ) in guard let data = data else {return}
            let decoder = JSONDecoder()
            
            do {
                let parsingData = try decoder.decode([Product].self, from: data)
                
                completion(parsingData)
                
            }catch{
                print("Parsing error")
            }
        }
        
        task.resume()
    }
    
    @IBAction func onClickSubmit(_ sender: Any) {
        let productId = textField.text ?? "1"
        let url = URL(string:  "https://dummyjson.com/products/")!
        print(url)
        fetchingApiData(URL: url) { result in
            self.data = result
            print(self.data)
            Dispatch.DispatchQueue.main.async {
                self.tableCell.reloadData()
            }
        }
    }
    
}

extension SecondController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = data[indexPath.row].title
        cell?.detailTextLabel?.text = String(data[indexPath.row].price)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}

struct Product : Decodable {
    var id: Int
    var title: String
    var description: String
    var price: Double
}
