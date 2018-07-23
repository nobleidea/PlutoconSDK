//
//  DetailDataVerticalView.swift
//  Plutocon
//
//  Created by 김동혁 on 2018. 2. 9..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import UIKit

@IBDesignable class DetailDataVerticalView: UIView {
    public static let Identifier = "DetailDataVerticalView"
    
    @IBInspectable var isEditable: Bool = false {
        didSet {
            imageArrow.isHidden = !isEditable
        }
    }
    @IBInspectable var title: String = "" {
        didSet {
            labelTitle.text = title
        }
    }
    @IBInspectable var value: String = "" {
        didSet {
            labelValue.text = value
        }
    }
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var imageArrow: UIImageView!
    
    var completion: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    private func loadNib() {
        Bundle.main.loadNibNamed(DetailDataVerticalView.Identifier, owner: self, options: nil)
        viewContainer.frame = bounds
        viewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(viewContainer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelTitle.text = title
        labelValue.text = value
        
        imageArrow.isHidden = !isEditable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editSelect))
        labelValue.isUserInteractionEnabled = true
        labelValue.addGestureRecognizer(tapGesture)
    }
    
    @objc func editSelect() {
        if isEditable {
            completion?()
        }
    }
}
