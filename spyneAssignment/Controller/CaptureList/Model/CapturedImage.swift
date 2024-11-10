//
//  CapturedImage.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 08/11/24.
//

import Foundation
import RealmSwift
import Realm
import UIKit
import CoreImage
///  Capture Image Model
class CapturedImage: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var imageURI: String // URI where the image is saved locally
    @Persisted var imageName: String
    @Persisted var imageData: Data
    @Persisted var captureDate: Date
    @Persisted var uploadStatus: String // "Pending", "Uploading", "Completed"
    @Persisted var uploadProgress: Int = 0
}
