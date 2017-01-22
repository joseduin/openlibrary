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
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!

    
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
        
        // Clear element after load the search result value
        titulo.text = ""
        autores.text = ""
        
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
                        self.loadData(data: datos!)
                    }
                } else {
                    self.message(message: "problemas con Internet)")
                }
            }
        }
        
        let dt = sesion.dataTask(with: url!, completionHandler: bloque)
        dt.resume()
    }
    
    func loadData(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
            let dic0 = json as! NSDictionary
            let dic1 = dic0["ISBN:\(searchText.text!)"] as! NSDictionary
            self.titulo.text = dic1["title"] as! NSString as String
            
            var nombreAutores = ""
            var i = 0
            if let listaAutores = dic1["authors"] as? NSArray {
                for autor in listaAutores {
                    let dicAutor = autor as! Dictionary<String,String>
                    if (i == 0) {
                        nombreAutores += "\(dicAutor["name"]!)"
                    } else {
                        nombreAutores += "\n \(dicAutor["name"]!)"
                    }
                    i = i + 1
                }
                self.autores.text = "\(i == 1 ? "Autor: " : "Autores: ")\(nombreAutores)"
            }
            
            if dic1["cover"] != nil {
                
                let imgSize = dic1["cover"] as! NSDictionary
                
                var urlImagen = ""
                if (imgSize["medium"] != nil) {
                    urlImagen = (imgSize["medium"] as! NSString) as String
                } else if (imgSize["small"] != nil) {
                    urlImagen = (imgSize["small"] as! NSString) as String
                } else {
                    urlImagen = (imgSize["large"] as! NSString) as String
                }
                
                let urlDelLibro = NSURL(string: urlImagen)
                self.portada.image = UIImage(data: NSData(contentsOf: urlDelLibro! as URL)! as Data)!
            } else {
                self.portada.image = UIImage(named: "placeholder")
            }

        } catch _ {
            
        }
    }
    
    func message(message: String) {
        let alert = UIAlertController(title: "Open Library", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

