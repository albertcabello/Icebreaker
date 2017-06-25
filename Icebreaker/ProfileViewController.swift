//
//  TestViewController.swift
//  Icebreaker
//
//  Created by Alberto Cabello on 6/22/17.
//  Copyright © 2017 Alberto Cabello. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var networkController:NetworkController!
    var user:User?
    var nvc:UINavigationController!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        imagePicker.delegate = self
        nvc.delegate = self
        
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let label = UILabel(frame: CGRect(x: 20, y: 90, width: 125, height: 200))
        label.text = "Test"
        self.view.addSubview(label)
        
        
        
        let imageButton = UIButton(frame: CGRect(x: 20, y: 300, width: 125, height: 200))
        imageButton.setTitle("Pick image", for: .normal)
        imageButton.addTarget(self, action: #selector(ProfileViewController.go(sender:)), for: .touchUpInside)
        imageButton.backgroundColor = UIColor.white
        imageButton.setTitleColor(UIColor.black, for: .normal)
        imageButton.layer.cornerRadius = 5
        imageButton.layer.borderWidth = 1
        self.view.addSubview(imageButton)
        
    }
    
    func go(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 20, y: 500, width: 125, height: 200)
        self.view.addSubview(imgView)
        dismiss(animated: true, completion: nil)
        networkController.uploadImage(image: image)
    }
    
    
}
