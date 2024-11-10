//
//  CaptureVC.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 09/11/24.
//

import UIKit
import AVFoundation
import RealmSwift
//class CaptureVC: UIViewController {
//    private let viewModel = CaptureViewModel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewModel.setupCaptureSession()
//        // Do any additional setup after loading the view.
//    }
//    
//    @IBAction func captureImageAction(_ sender: Any) {
//        let settings = AVCapturePhotoSettings()
 //        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//}


import UIKit
import AVFoundation

class CaptureVC: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    lazy var viewModel = CaptureViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarButton()
    }
    
    
    func setupRightBarButton() {
        // Create a right bar button with the title "Capture"
        let captureButton = UIBarButtonItem(title: "Capture", style: .plain, target: self, action: #selector(capturePhoto))
        navigationItem.rightBarButtonItem = captureButton
    }
    
    @objc func capturePhoto(){
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            presentCameraSettings()
        }
        
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        } catch let error {
            print("Error Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    // AVCapturePhotoCaptureDelegate method
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!.localizedDescription)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error capturing image: \(String(describing: error))")
            return
        }
        viewModel.saveImageToRealm(image: image)
    }

    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Camera Access",
                                                message: "Camera access is denied, Please give access then continue.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        self.present(alertController, animated: true)
    }
    
}
