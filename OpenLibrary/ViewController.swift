//
//  ViewController.swift
//  OpenLibrary
//
//  Created by Jose Duin on 1/12/17.
//  Copyright © 2017 Jose Duin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var restfullResult: UITextView!
    
    let url_path: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red:205/255.0, green: 0/255.0, blue: 15/255.0, alpha: 1)
        self.searchText.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        self.view.endEditing(true)
        return false
    }
    

    func search() {
        if (searchText.text?.isEmpty)! {
            message(message: "Por favor, introduzca el ISBN del libro a buscar")
            return
        }
        
        // Clear TextView after load the search result value
        restfullResult.text = ""
        
        // Asincrono
        let urls = "\(self.url_path)\(searchText.text!)"
        let url = URL(string: urls)
        let sesion = URLSession.shared
        let bloque = { (datos: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.sync {
                if response != nil {
                    let texto: String = String(data: datos!, encoding: String.Encoding.utf8)!
                    if (texto == "{}") {
                        self.message(message: "Sin referencas")
                    } else {
                        self.restfullResult.text = texto
                    }
                } else {
                    self.message(message: "problemas con Internet)")
                }
            }
        }
        
        let dt = sesion.dataTask(with: url!, completionHandler: bloque)
        dt.resume()
    }
    
    func message(message: String) {
        let alert = UIAlertController(title: "Open Library", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

