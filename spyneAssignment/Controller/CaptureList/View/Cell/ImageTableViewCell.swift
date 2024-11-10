//
//  ImageTableViewCell.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 09/11/24.
//

import UIKit
protocol UploadImageDelegate: AnyObject {
    func didTapUploadImage(for cell:ImageTableViewCell)
}

class ImageTableViewCell: UITableViewCell {
    /// Variables
    static let identifier = "ImageTableViewCell"
    /// IBOutlets
    @IBOutlet weak var imageCapture: UIImageView!
    @IBOutlet weak var lblProgess: UILabel!
    @IBOutlet weak var lblImageName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnUpload: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var delegate: UploadImageDelegate?
    
    /// data set up
    var setData: CapturedImage? {
        didSet {
            guard let data = setData else {return}
            lblProgess.text = "Progress: \(data.uploadProgress)%"
            lblImageName.text = "Name: \(data.imageName)"
            lblStatus.text = "Status: \(data.uploadStatus)"
            switch data.uploadStatus {
            case "Failed":
                lblStatus.textColor = .red
                btnUpload.isHidden = false
            case "Pending":
                lblStatus.textColor = .lightGray
                btnUpload.isHidden = false
            case "Uploading":
                lblStatus.textColor = .systemBlue
                btnUpload.isHidden = true
            case "Completed":
                lblStatus.textColor = .green
                btnUpload.isHidden = true
            default:
                break
            }
            imageCapture.image = UIImage(data: data.imageData)
        }
    }
    /// upload  status actions
    @IBAction func didTapStatus(_ sender: UIButton) {
        if let delegate = self.delegate{
            delegate.didTapUploadImage(for: self)
        }
    }
}
