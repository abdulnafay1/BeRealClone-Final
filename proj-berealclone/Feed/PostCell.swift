//
//  PostCell.swift
//  proj-berealclone
//
//  Created by Nafay on 2/1/24.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var captionUsername: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var profilePhoto: UIImageView!
    
    private var imageDataRequest: DataRequest?
    
    @IBOutlet var blurView: UIVisualEffectView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    
    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell
        
        // Username
        if let user = post.user {
            usernameLabel.text = user.username
            captionUsername.text = user.username

            if let imageFile = user.profilephoto,
               let imageUrl = imageFile.url {
                
                // Use AlamofireImage helper to fetch remote image from URL
                imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                    switch response.result {
                    case .success(let image):
                        // Set image view image with fetched image
                        self?.profilePhoto.image = image
                        
                    case .failure(let error):
                        print("❌ Error fetching image: \(error.localizedDescription)")
                        break
                    }
                }
            }
        }

        

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                    self?.postImageView.layer.cornerRadius = 10
                    self?.postImageView.layer.masksToBounds = true
                    
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption
        


        // Date
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
        
        // A lot of the following returns optional values so we'll unwrap them all together in one big `if let`
        // Get the current user.
        if let currentUser = User.current,

            // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,

            // Get the date the given post was created.
           let postCreatedDate = post.createdAt,

            // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {
            
            print("worked")

            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            blurView.isHidden = abs(diffHours) < 24
        } else {

            // Default to blur if we can't get or compute the date's above for some reason.
            blurView.isHidden = false
            blurView.layer.cornerRadius = 10
            blurView.layer.masksToBounds = true
        }

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: P1 - Cancel image download
        
        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()

    }

}


extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
