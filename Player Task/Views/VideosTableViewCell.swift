//
//  VideosTableViewCell.swift
//  Player Task
//
//  Created by Vijay Guruju on 19/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import UIKit

class VideosTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bgView.layer.cornerRadius = 15
        self.bgView.layer.masksToBounds = true
        
        self.thumbImgView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
