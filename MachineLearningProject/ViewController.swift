//
//  ViewController.swift
//  MachineLearningProject
//
//  Created by Ezequiel Parada Beltran on 11/07/2020.
//  Copyright © 2020 Ezequiel Parada. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        detectarImagenes()
    }

    @IBAction func tomarFoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        } else {
            print("No se pudo acceder a la camara")
        }
        
        
        
    }
    @IBAction func seleccionarFoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("No se pudo tener acceso a la libreria de fotos")
        }
    }
    
    
    
    func detectarImagenes() {
        dataLabel.text = "Cargando..."
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            print("Ocurrio un error, no se pudo crear el modelo")
            
            return
        }
        
        let peticion = VNCoreMLRequest(model: model) { (request, error) in
            guard let resultados = request.results as? [VNClassificationObservation],
                let primerResultado = resultados.first else {
                    print("No se encontraron resultados")
                    return
            }
            
            DispatchQueue.main.async {
                self.dataLabel.text = "\(primerResultado.identifier)"
            }
        }
        
        guard let ciimageForUse = CIImage(image: self.dataImage.image!) else {
            print("No se ha podidiop crear una imagen CIIMAGE a partir de una UIImage")
            return
        }
        
        // COrrer peticion
        
        let handler = VNImageRequestHandler(ciImage: ciimageForUse)
        
        DispatchQueue.global().async {
            do {
                try handler.perform([peticion])
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
        
        
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            self.dataImage.contentMode = .scaleAspectFill
            self.dataImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        detectarImagenes()
    }
    
}


extension ViewController: UINavigationControllerDelegate{
    
}

