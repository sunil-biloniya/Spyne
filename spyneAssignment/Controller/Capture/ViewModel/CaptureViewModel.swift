//
//  CaptureViewModel.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 09/11/24.
//

import Foundation
import AVFoundation
import RealmSwift
import Combine

class CaptureViewModel: NSObject, ObservableObject {
    /// Variables
    var cameraAccess: Bool = false
    @Published var capturedImages: [CapturedImage] = []
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var realm = try! Realm()
    var previewLayer: AVCaptureVideoPreviewLayer?
    /// Save Images to Realm Data base
     func saveImageToRealm(image: UIImage) {
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent("\(imageName).jpg")
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
            let capturedImage = CapturedImage()
            capturedImage.imageURI = imagePath.path
            capturedImage.imageName = imageName
            capturedImage.captureDate = Date()
            capturedImage.uploadStatus = "Pending"
            capturedImage.imageData = jpegData
            
            try? realm.write {
                realm.add(capturedImage)
                self.capturedImages.append(capturedImage)
            }
        }
    }
    /// Get Documents Directory
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

