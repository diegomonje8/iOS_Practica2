//
//  ViewController.swift
//  cicePractica2
//
//  Created by MAC on 4/5/21.
//

import UIKit
import CoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var photoCollection: UICollectionView!
    var imagePicked : UIImage = UIImage()
    var ac : UIAlertController!
    let viewModel = PhotoViewModel()
    var newPhoto = PhotoModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Photo Manager"
        ac = UIAlertController(title: "Nombre", message: nil, preferredStyle: .alert)
        alert()
        viewModel.getAllPhotos()
        print("\(viewModel.photos.count)")
    }
    
    
    

    @IBAction func addPhotoTapped(_ sender: Any) {
        let picker = UIImagePickerController()
         
         picker.sourceType = .photoLibrary
         picker.mediaTypes = [kUTTypeMovie  as String, kUTTypeImage as String]
         picker.delegate = self
         
         picker.allowsEditing = true
         
         present(picker,animated: true,completion: nil)
    
    }
    
    func alert() {
        
        self.ac.addTextField(configurationHandler: {(action) in
           self.ac.textFields![0].delegate = self
        })
     
        self.ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action) in
            
        }))
        
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
            if !self.ac.textFields![0].text!.isEmpty
            {
                if let text = self.ac.textFields?[0].text {
                    self.newPhoto.title = text
                }
                self.viewModel.addPhoto(image: self.newPhoto)
                self.viewModel.getAllPhotos()
                self.photoCollection.reloadData() 
                
            }
            else{
                self.ac.message = "Error"
            }
        }))
        
  
        self.ac.actions[1].isEnabled = false
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
        
            imagePicked = image
            
            dismiss(animated: true, completion: nil) //Cierra cualquer ventana modal
            
            let timestamp = NSDate().timeIntervalSince1970
            let timestampString = String(format: "%.0f", timestamp)
            let fileName = String(timestampString + ".jpg")
            let completeFilePath = getDocsDirectory().appendingPathComponent(fileName)
            print(completeFilePath)
            
            if let jpegData = image.jpegData(compressionQuality: 0.8)
            {
                do {
                    try? jpegData.write(to: completeFilePath)
                }
//                catch  {
//                    print("Error de escritura")
//                }
            }
            
            
            newPhoto = PhotoModel(uid: 0, filename: fileName, title: "", description: "", tags: "")
            print(fileName)
        
            present(self.ac, animated: true, completion: nil)
            
        }
                    
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        if  newString != ""{
            
            ac.actions[1].isEnabled = true
        } else {
            ac.actions[1].isEnabled = false
        }
        return true
    }
    
    func getDocsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
   

}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! PhotoCollectionViewCell
        cell.title.text = viewModel.photos[indexPath.row].title
        let imagePath = getDocsDirectory().appendingPathComponent(viewModel.photos[indexPath.row].filename)
        cell.image.image = UIImage(contentsOfFile: imagePath.path)
        
        return cell
    }
    

    
  
   
    
    
    
}
