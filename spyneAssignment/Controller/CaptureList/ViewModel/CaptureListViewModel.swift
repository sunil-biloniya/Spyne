//
//  CaptureViewModel.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 08/11/24.
//

import Foundation
import RealmSwift
import Combine

class CaptureListViewModel: NSObject, ObservableObject, URLSessionTaskDelegate {
    @Published var images: [CapturedImage] = []
    var realm = try! Realm()
    var progressHandler: ((CapturedImage) -> Void)?
    private var notificationToken: NotificationToken?
    private var taskToImageMap: [URLSessionTask: CapturedImage] = [:]
    
    override init() {
        super.init()
        fetchImages()
    }
    
    private func fetchImages() {
        let results = realm.objects(CapturedImage.self)
        notificationToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let initialResults):
                self?.images = Array(initialResults)
            case .update(let updatedResults, _, _, _):
                self?.images = Array(updatedResults)
            case .error(let error):
                debugPrint("Error observing Realm changes: \(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func uploadImage(_ image: CapturedImage, completion: @escaping (Bool) -> Void) {
        let parameters = [[
                "key": "image",
                "src": image.imageURI,
                "type": "file"
            ]
        ] as [[String: Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        for param in parameters {
            if param["disabled"] != nil { continue }
            let paramName = param["key"]!
            body += "--\(boundary)\r\n".data(using: .utf8)!
            body += "Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(paramName)\"\r\n".data(using: .utf8)!
            let mimeType = "image/jpeg"
            body += "Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!
            body += image.imageData
            body += "\r\n".data(using: .utf8)!
        }
        body += "--\(boundary)--\r\n".data(using: .utf8)!
        let postData = body
        guard let url = URL(string: "https://www.clippr.ai/api/upload") else { return }
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint("Request failed with error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                debugPrint("Upload failed with error: \(String(describing: error))")
                DispatchQueue.main.async {
                    try? self.realm.write {
                        image.uploadStatus = "Failed"
                    }
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                try? self.realm.write {
                    image.uploadStatus = "Completed"
                    image.uploadProgress = 100
                }
                completion(true)
            }
            guard let data = data else {
                debugPrint("No data received")
                return
            }
            // debugPrint the response
            if let responseString = String(data: data, encoding: .utf8) {
                debugPrint(responseString)
            } else {
                debugPrint("Failed to convert response data to string")
            }
        }
        taskToImageMap[task] = image
        task.resume()
        DispatchQueue.main.async {
            try? self.realm.write {
                image.uploadStatus = "Uploading"
            }
        }
    }
    
    // URLSessionTaskDelegate method to track upload progress
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let image = taskToImageMap[task] else { return }
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        let progressPercentage = Int(progress * 100)
        DispatchQueue.main.async {
            try? self.realm.write {
                image.uploadProgress = progressPercentage
            }
            self.progressHandler?(image)
        }
    }
    
    private func getImageID(for task: URLSessionTask) -> String? {
        // Logic to find the imageID for the current task, assuming imageID is passed somewhere in your request
        return task.taskDescription
    }
    
    func scheduleUploadCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Upload Complete"
        content.body = "Your image upload has successfully completed."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "UploadComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}