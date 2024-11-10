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
    static let identifier = "ImageTableViewCell"
    @IBOutlet weak var imageCapture: UIImageView!
    
    @IBOutlet weak var lblProgess: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    weak var delegate: UploadImageDelegate?
    var setData: CapturedImage? {
        didSet {
            guard let data = setData else {return}
            lblProgess.text = String(data.uploadProgress) + "%"
            btnStatus.setTitle(data.uploadStatus, for: .normal)
            switch data.uploadStatus {
            case "Failed":
                btnStatus.setTitleColor(.red, for: .normal)
            case "Pending":
                btnStatus.setTitleColor(.lightGray, for: .normal)
            case "Uploading":
                btnStatus.setTitleColor(.systemBlue, for: .normal)
            case "Completed":
                btnStatus.setTitleColor(.green, for: .normal)
            default:
                break
            }
            imageCapture.image = UIImage(data: data.imageData)
        }
    }
    
    @IBAction func didTapStatus(_ sender: UIButton) {
        if let delegate = self.delegate{
            delegate.didTapUploadImage(for: self)
        }
    }
}
