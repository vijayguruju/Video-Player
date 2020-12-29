//
//  VideosViewController.swift
//  Player Task
//
//  Created by Vijay Guruju on 17/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleSignIn
class VideosViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    var videos = [Videos]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "VideosTableViewCell")
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        tableView.tableHeaderView = headerView
        getVideos()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutClicked))
    }
    @objc func logoutClicked(){
        GIDSignIn.sharedInstance()?.signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
        
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell") as! VideosTableViewCell
        let videoData = self.videos[indexPath.row]
        cell.titleLbl.text = videoData.title
        cell.descLbl.text = videoData.description
        cell.tag = indexPath.row
        cell.thumbImgView.sd_setImage(with: URL(string: videoData.thumb), placeholderImage: UIImage(named: "placeholder"))

        //cell.thumbImgView.setImageFromURl(stringImageUrl: videoData.thumb)
        
        return cell
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        
        let videoData = self.videos[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? VideosTableViewCell
        detailVC.videoURL = videoData.url
        detailVC.videoTitle = videoData.title
        detailVC.videoDesc = videoData.description
        detailVC.videos = self.videos
        if let thumbImage = cell?.thumbImgView.image{
            detailVC.thumbImage = thumbImage
        }
        
        self.navigationController?.show(detailVC, sender: self)

    }
    
    //MARK:- Get Video List API Call
    func getVideos(){
        if Utility.shared.isInternetAvailable(){
            guard let requestUrl = URL(string: API.baseUrl) else {return }
        let task = URLSession.shared.dataTask(with: requestUrl, completionHandler: {(data, error, response) -> Void in
            
            let decoder = JSONDecoder()
            
            if let responseData = data{
                if let videosJson = try? decoder.decode([Videos].self, from: responseData){
                    self.videos = videosJson
                    DispatchQueue.main.async {
                        
                    self.tableView.reloadData()
                    }
                    //print(videosJson)
                }
                
            }
            })
            
            
        task.resume()
    }
    
    else{
            Utility.shared.showAlert(message: "No Internet Connection", targetVC: self)
    }

}
}


extension UIImageView{
func setImageFromURl(stringImageUrl url: String){
    if let url = URL(string: url) {
        DispatchQueue.global(qos: .default).async{
            if let data = try? Data(contentsOf: url as URL) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data as Data)
                }
            }
        }
    }
 }
}
