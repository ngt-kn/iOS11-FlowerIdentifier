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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
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
    
    // Present imagePicker when camera button pressed
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

