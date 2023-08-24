//
//  BoardNavigationBar.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 24/08/2023.
//

import UIKit

protocol BoardNavigationBarDelegate: AnyObject {
    func back()
    func undo()
    func redo()
}

class BoardNavigationBar: UIView {
    weak var delegate: BoardNavigationBarDelegate?
    let itemsColor = UIColor.white
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = itemsColor
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var undoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "arrow.uturn.backward.circle",
                            withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        button.setImage(image, for: .normal)
        button.tintColor = itemsColor
        button.addTarget(self, action: #selector(undoButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var redoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "arrow.uturn.forward.circle",
                            withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        button.setImage(image, for: .normal)
        button.tintColor = itemsColor
        button.addTarget(self, action: #selector(redoButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, undoButton, redoButton])
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
            stackView.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor, constant: 6),
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
    
    @objc func backButtonPressed(_ sender: UIButton) {
        delegate?.back()
    }
    
    @objc func undoButtonPressed(_ sender: UIButton) {
        delegate?.undo()
    }
    
    @objc func redoButtonPressed(_ sender: UIButton) {
        delegate?.redo()
    }
}
