//
//  ViewController.swift
//  SeaFood
//
//  Created by Асхат Баймуканов on 17.05.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //включаем возможность использовать камеру, функциональность камеры
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    //момент когда юзер выбрал картинку для дальнейшей обработки
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            //конвертируем просто имедж в кор имедж чтобы мы могли работать с этим имедж используя фреймворки вижн и корМЛ
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    func detect(image: CIImage) {
        
        //создали объект модел используя контейнер ВНкорМодл и создали новый объект Инсепшнв3 и используя его проперти модл
        //эту модел мы будем исп для классификации наших картинок
        guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    //self.navigationItem.title = "Not hotdog!"
                    self.navigationItem.title = firstResult.identifier
                    print(firstResult.identifier)
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try! handler.perform([request])
        }
        catch {
            print(error)
        }
        
    }
    
    
    @IBAction func caneraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

