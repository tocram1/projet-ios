//
//  ViewController.swift
//  SamyTheoProjet
//
//  Created by etudiant on 21/09/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func onClickStart(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(identifier: "SecondController")
        self.present(controller, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

