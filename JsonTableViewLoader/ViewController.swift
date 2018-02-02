//
//  ViewController.swift
//  JsonTableViewLoader
//
//  Created by BIBIN THOMAS on 1/30/18.
//  Copyright © 2018 BIBIN THOMAS. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController {
    
    var managedObjContext: NSManagedObjectContext?
    var latinQuoteEntity: NSEntityDescription?
    
    var quoteArr : [LatinQuotesData] = []

    @IBAction func loadButtonTapped(_ sender: UIButton) {
        let url =
        "https://jsonplaceholder.typicode.com/posts/\(random(range: 1..<101))"
        getJsonFromURL(resource:url)
    }
    
    // range based random num gen
    func random(range: Range<Int>) -> Int {
        return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        managedObjContext = appDelegate.persistentContainer.viewContext
        latinQuoteEntity = NSEntityDescription.entity(forEntityName: "LatinQuoteEntity", in: managedObjContext!)!

        // used to find out where your sqlite database rests in the simulator
//        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        var docsDir = dirPaths[0]
//        print(docsDir)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var quoteTextView: UITextView!
    
    func getJsonFromURL(resource: String) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: resource)!
        
        //        var latinQuoteFinal: LatinQuotesData? = nil
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if let jsonData = data {
//                    print out the json payload as a string
//                    if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
//                        print(jsonString)
//                    }
                    
                    let jsonDecoder = JSONDecoder()
                    guard let latinQuote = try?
                        jsonDecoder.decode(LatinQuotesData.self,
                                           from: jsonData) else { return }
                    
                    DispatchQueue.main.async {
                        
                        //populate the text view with json payload in string
                        self.quoteTextView.text = "userId: \(latinQuote.userId) \n"
                        self.quoteTextView.text = self.quoteTextView.text + "id: \(latinQuote.id) \n"
                        self.quoteTextView.text = self.quoteTextView.text + "title: \(latinQuote.title) \n"
                        self.quoteTextView.text = self.quoteTextView.text + "body: \(latinQuote.body) \n\n"
                        
                        
                        let fetchRequest = NSFetchRequest<LatinQuoteEntity>(entityName: "LatinQuoteEntity")
                        fetchRequest.predicate = NSPredicate(format: "id == %i", latinQuote.id)
                        
                        do {
                            let fetchedQuotes = try self.managedObjContext?.fetch(fetchRequest)
                            
                            
                            if fetchedQuotes?.count != 0 {
                                print("Quote already exists....Dont save")
//                                for quote in fetchedQuotes! {
//                                    print(quote.value(forKey: "id")!)
//                                    print(quote.value(forKey: "userId")!)
//                                    print(quote.value(forKey: "title")!)
//                                    print(quote.value(forKey: "body")!)
//                                }
                                return
                            }
                            
                            print("no record found.... therefore save")
                            let latinQuoteManagedObj =
                                NSManagedObject(entity: self.latinQuoteEntity!, insertInto: self.managedObjContext)
                            latinQuoteManagedObj.setValue(latinQuote.id, forKey: "id")
                            latinQuoteManagedObj.setValue(latinQuote.userId, forKey: "userId")
                            latinQuoteManagedObj.setValue(latinQuote.title, forKey: "title")
                            latinQuoteManagedObj.setValue(latinQuote.body, forKey: "body")
                            guard let appDelegate =
                                UIApplication.shared.delegate as? AppDelegate else {
                                    return
                            }
                            appDelegate.saveContext()
                        } catch {
                            fatalError("Failed to fetch")
                        }
                        
                        
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    func updateQuoteArray(quote: LatinQuotesData) {
        quoteArr.append(quote)
    }


}

