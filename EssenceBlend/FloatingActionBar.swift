//
//  FloatingActionBar.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 24/08/2023.
//

import UIKit

class FloatingActionBar: UIView {
    
    let openLockImage = UIImage(systemName: "lock.open")
    let closedLockImage = UIImage(systemName: "lock")
    let itemsColor = UIColor.white
    
    lazy var zoomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("100%", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = itemsColor
        return button
    }()
    
    lazy var lockButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(openLockImage, for: .normal)
        button.tintColor = itemsColor
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [zoomButton, lockButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.contentView.addSubview(stackView)
        return blurredEffectView
    }()
        
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        addSubview(effectView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: effectView.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor, constant: -6),

            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func layout() {
        layer.cornerRadius = frame.height * 0.5
    }
}
