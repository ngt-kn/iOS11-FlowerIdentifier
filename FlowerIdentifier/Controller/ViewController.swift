//
//  ViewController.swift
//  FlowerIdentifier
//
//  Created by Kenneth Nagata on 5/15/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    
    


    @IBOutlet weak var cameraImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    // imagePicker delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            cameraImageView.image = selectedImage
            guard let ciimage = CIImage(image: selectedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(flowerImage: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    // Process the image for classification
    func detect(flowerImage: CIImage) {
        // Load the model
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Error loading CoreML model.")
        }

        // Get the classification
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }

            // set the navbar title to result
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.capitalized
                self.wikipediaRequest(flowerName: firstResult.identifier)
            }
        }

        // process the request
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func wikipediaRequest(flowerName: String) {
 
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got the wikipedia")
                print(response)
                self.processResponse(response: JSON(response.result.value!))
            }
        }
    }
    
    func processResponse(response: JSON) {
        
        let pageID = response["query"]["pageids"][0].stringValue
        let description = response["query"]["pages"][pageID]["extract"].stringValue
        
        descriptionLabel.text = description
        
        
        
        
        
    }
    
    
    
    // Present imagePicker when camera button pressed
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

