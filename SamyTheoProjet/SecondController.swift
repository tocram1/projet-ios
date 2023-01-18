//
//  SecondController.swift
//  SamyTheoProjet
//
//  Created by etudiant on 21/09/2022.
//

import Foundation
import UIKit
import FirebaseCore

class SecondController: UIViewController,UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate {
    
    var data = [Product]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        UNUserNotificationCenter.current().delegate = self
        // Do any additional setup after loading the view.
        
        let url = URL(string:  "https://dummyjson.com/products/")!
        print(url)
        fetchingApiData(URL: url) { result in
            self.data = result.products
            Dispatch.DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func fetchingApiData(URL url:URL, completion: @escaping (Products)-> Void) {
        let task = URLSession.shared.dataTask(with: url ) {( data, response, error ) in guard let data = data else {return}
            let decoder = JSONDecoder()
            
            do {
                let parsingData = try decoder.decode(Products.self, from: data)
                
                completion(parsingData)
                
            }catch{
                print("Parsing error")
            }
        }
        
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = data[indexPath.row].title
        cell?.detailTextLabel?.text = String(data[indexPath.row].price) + " $"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
                        
        sendNotificationIn5Seconds(title:String(data[row].title), price:String(data[row].price) + " $")
    }
    
    func sendNotificationIn5Seconds(title: String, price: String) {
        let centre = UNUserNotificationCenter.current()
        centre.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: ", error.localizedDescription)
                return
            }
        }
        
        centre.getNotificationSettings { (settings) in
            if settings.authorizationStatus != UNAuthorizationStatus.authorized {
                print("Not Authorised")
            } else {
                print("Authorised")
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: price, arguments: nil)
                content.categoryIdentifier = "Category"
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                 
                // Schedule the notification.
                let request = UNNotificationRequest(identifier: "ZeroSecond", content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                 
                let completeAction = UNNotificationAction.init(identifier: "Complete", title: "Complete", options: UNNotificationActionOptions())
                let editAction = UNNotificationAction.init(identifier: "Edit", title: "Edit", options: UNNotificationActionOptions.foreground)
                let deleteAction = UNNotificationAction.init(identifier: "Delete", title: "Delete", options: UNNotificationActionOptions.destructive)
                let categories = UNNotificationCategory.init(identifier: "Category", actions: [completeAction, editAction, deleteAction], intentIdentifiers: [], options: [])
                 
                centre.setNotificationCategories([categories])
                 
                center.add(request, withCompletionHandler: nil)
            }
        }
    }
}

struct Product : Decodable {
    var id: Int
    var title: String
    var description: String
    var price: Double
}

struct Products : Decodable {
    var products: [Product]
}
