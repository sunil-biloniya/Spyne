//
//  CaptureListVC.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 08/11/24.
//

import UIKit
import RealmSwift
import Combine
import UserNotifications

class CaptureListVC: UIViewController {
    /// Outlets
    @IBOutlet weak var tableView: UITableView!
    /// Variables
    private var viewModel = CaptureListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
    
    /// Tableview configrations
    private func configTableView(){
        tableView.register(UINib(nibName: ImageTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ImageTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    /// Binding observer
    private func setupBindings() {
        viewModel.$images
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        tableView.setBackgroundMessage(viewModel.images.count == 0 ? "Capture images not found." : nil)

    }
    /// Add Image actions
    @IBAction func addImageAction(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CaptureVC") as? CaptureVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
/// UITableViewDataSource & UITableViewDelegate
extension CaptureListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {return UITableViewCell()}
        cell.setData = viewModel.images[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
/// Upload Image click action delegate
extension CaptureListVC:UploadImageDelegate {
    func didTapUploadImage(for cell: ImageTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let item = viewModel.images[indexPath.row].uploadStatus
        if item == "Pending" || item == "Failed" {
            viewModel.uploadImage(viewModel.images[indexPath.row], completion: { success in
                DispatchQueue.main.async(execute: {
                    if success {
                        self.viewModel.scheduleUploadCompleteNotification()
                    }
                    cell.setData = self.viewModel.images[indexPath.row]
                })
            })
        }
        /// Image upload progress handler
        viewModel.progressHandler = { [weak self] image in
            guard let self = self else { return }
            if self.viewModel.images[indexPath.row].id == image.id {
                DispatchQueue.main.async {
                    cell.setData = self.viewModel.images[indexPath.row]
                }
            }
        }
    }
}
