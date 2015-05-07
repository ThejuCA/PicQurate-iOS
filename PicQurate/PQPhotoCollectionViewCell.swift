//
//  ImageViewCollectionViewCell.swift
//  PicQurate
//
//  Created by SongXujie on 4/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class PQPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: AVImageView!
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var chainButton: UIButton?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var captionTextView: UITextView?
    
    private var cachedPhoto: PQPhoto?
    var photo: PQPhoto!
    
    func initializeWithPhoto(photo: PQPhoto) {
        
        self.photo = photo;
        
        if (self.cachedPhoto?.objectId == self.photo?.objectId) {
            //View already initialized, do nothing
        } else {
            self.cachedPhoto = photo;
            
            self.imageView.file = photo.file;
            self.imageView.loadInBackground();
            
            var query1 = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
            query1.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.likeButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            var query2 = PQChain.query();
            query2.whereKey("photo", equalTo: self.photo);
            query2.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.chainButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            self.locationButton?.setTitle(self.photo.locationString, forState: .Normal);
            
            self.captionTextView?.text = self.photo.caption;
            
        }
        
        
    }
}