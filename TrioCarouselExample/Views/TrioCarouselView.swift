//
//  TrioCarouselView.swift
//  TrioCarouselExample
//
//  Created by Yilmaz Edis on 13.09.2023.
//

import UIKit

protocol TrioCarouselViewDelegate: AnyObject {
  func trioCarousel(didSelect index: Int)
  func trioCarousel(imageForCenterAt index: Int)
}

final class TrioCarouselView: UIView {

  // MARK: - IBOutlets

  @IBOutlet private weak var leftImageView: UIImageView!
  @IBOutlet private weak var leftCenterX: NSLayoutConstraint!
  @IBOutlet private weak var leftWidth: NSLayoutConstraint!
  @IBOutlet private weak var leftHeight: NSLayoutConstraint!

  @IBOutlet private weak var rightImageView: UIImageView!
  @IBOutlet private weak var rightCenterX: NSLayoutConstraint!
  @IBOutlet private weak var rightWidth: NSLayoutConstraint!
  @IBOutlet private weak var rightHeight: NSLayoutConstraint!

  @IBOutlet private weak var centerImageView: UIImageView!
  @IBOutlet private weak var centerCenterX: NSLayoutConstraint!
  @IBOutlet private weak var centerWidth: NSLayoutConstraint!
  @IBOutlet private weak var centerHeight: NSLayoutConstraint!

  @IBOutlet private weak var backImageView: UIImageView!
  @IBOutlet private weak var backCenterX: NSLayoutConstraint!
  @IBOutlet private weak var backWidth: NSLayoutConstraint!
  @IBOutlet private weak var backHeight: NSLayoutConstraint!

  @IBOutlet private weak var onClickCenterView: UIView!
  @IBOutlet private weak var onClickLeftView: UIView!
  @IBOutlet private weak var onClickRightView: UIView!

  // MARK: - Properties

  weak var delegate: TrioCarouselViewDelegate?

  private let numberOfStates = 4
  private var currentState = 1

  private var images: [UIImage] = []
  private var currentImageIndex = 1

  private enum State: Int {
    case centerRight, centerCenter, centerLeft, centerBack
  }

  private enum ImageDirection: CGFloat {
    case left = -140
    case right = 140
    case center = 0
  }

  private enum ImageSize: CGFloat {
    case small = 70
    case big = 140
    case back = 20
  }

  private var getBackImageIncreaseIndex: Int {
    (currentImageIndex + 2) % images.count
  }

  private var getBackImageDecreaseIndex: Int {
    (currentImageIndex - 2 + images.count) % images.count
  }

  private var getStateIndex: Int {
    images.count == 2 ? currentImageIndex % numberOfStates : currentState
  }

  // MARK: - View's Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupNib()
    prepareView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupNib()
    prepareView()
  }

  func configure(images: [UIImage]) {
    self.images = images
    initItems()
  }

  // MARK: - Preparation

  private func initItems() {
    currentImageIndex = 1
    currentState = 1
    emptyImages()
    positionStates(state: .centerCenter)
    switch images.count {
    case 1:
      currentImageIndex = 0
      updateCenterItem(with: 0)
      centerImageView.image = images[0]
      leftImageView.isHidden = true
      rightImageView.isHidden = true
      backImageView.isHidden = true
    case 2:
      updateCenterItem(with: 1)
      leftImageView.image = images[0]
      centerImageView.image = images[1]
      leftImageView.isHidden = false
      rightImageView.isHidden = true
      backImageView.isHidden = true
    case 3:
      updateCenterItem(with: 1)
      leftImageView.image = images[0]
      centerImageView.image = images[1]
      rightImageView.image = images[2]
      leftImageView.isHidden = false
      rightImageView.isHidden = false
      backImageView.isHidden = false
    default:
      updateCenterItem(with: 1)
      leftImageView.image = images[0]
      centerImageView.image = images[1]
      rightImageView.image = images[2]
      backImageView.image = images[3]
      leftImageView.isHidden = false
      rightImageView.isHidden = false
      backImageView.isHidden = false
    }
  }

  func setupNib() {
    let bundle = Bundle(for: Self.self)
    guard let view = UINib(nibName: String(describing: Self.self),
                           bundle: bundle).instantiate(
      withOwner: self,
      options: nil).first as? UIView else {
      fatalError("Error loading \(self) from nib")
    }
    addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Prepare Gestures

  private func prepareView() {
    prepareSwipeGesture()
    prepareTapGesture()
  }

  private func emptyImages() {
    leftImageView.image = nil
    centerImageView.image = nil
    rightImageView.image = nil
    backImageView.image = nil

    leftImageView.alpha = 1
    centerImageView.alpha = 1
    rightImageView.alpha = 1
    backImageView.alpha = 0
  }

  private func prepareSwipeGesture() {
    let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
    leftGesture.direction = .left
    addGestureRecognizer(leftGesture)

    let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
    rightGesture.direction = .right
    addGestureRecognizer(rightGesture)
  }

  private func prepareTapGesture() {
    let tapCenterGesture = UITapGestureRecognizer(target: self, action: #selector(centerViewTapped))
    onClickCenterView.addGestureRecognizer(tapCenterGesture)

    let tapLeftGesture = UITapGestureRecognizer(target: self, action: #selector(leftViewTapped))
    onClickLeftView.addGestureRecognizer(tapLeftGesture)

    let tapRightGesture = UITapGestureRecognizer(target: self, action: #selector(rightViewTapped))
    onClickRightView.addGestureRecognizer(tapRightGesture)
  }

  // MARK: - Functions to handle view tap

  @objc func centerViewTapped() {
    // if no images, no tap
    guard images.count > 0 else { return }

    print("View Center Tapped!")
    delegate?.trioCarousel(didSelect: currentImageIndex)
  }

  @objc func leftViewTapped() {
    guard images.count > 1 else { return }

    print("View Left Tapped!")
    updateRightSwipe()
  }

  @objc func rightViewTapped() {
    guard images.count > 1 else { return }

    print("View Right Tapped!")
    updateLeftSwipe()
  }

  // MARK: - Swipe Action

  @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
    guard images.count > 1 else { return }
    switch gesture.direction {
    case .left:
      updateLeftSwipe()
    case .right:
      updateRightSwipe()
    default:
      return
    }
  }

  // MARK: - State Control

  private func goLeft() {
    currentState = (currentState - 1 + numberOfStates) % numberOfStates
    currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
  }

  private func goRight() {
    currentState = (currentState + 1) % numberOfStates
    currentImageIndex = (currentImageIndex + 1) % images.count
  }

  private func updateItem(with index: Int) {
    let imageViews: [UIImageView] = [backImageView, rightImageView, leftImageView, centerImageView]
    if let targetImageView = imageViews.first(where: { $0.alpha == 0 }) {
      targetImageView.image = images[index]
    }
  }

  private func updateCenterItem(with index: Int) {
    delegate?.trioCarousel(imageForCenterAt: index)
  }
}



// MARK: - States

private extension TrioCarouselView {
  private func updateRightSwipe() {
    updateItem(with: getBackImageDecreaseIndex)
    goLeft()
    updateCenterItem(with: currentImageIndex)
    positionStates(state: State(rawValue: getStateIndex)!)
    UIView.animate(withDuration: 0.4) {
      self.alphaStates(state: State(rawValue: self.getStateIndex)!)
      self.layoutIfNeeded()
    }
  }

  private func updateLeftSwipe() {
    updateItem(with: getBackImageIncreaseIndex)
    goRight()
    updateCenterItem(with: currentImageIndex)
    positionStates(state: State(rawValue: getStateIndex)!)
    UIView.animate(withDuration: 0.4) {
      self.alphaStates(state: State(rawValue: self.getStateIndex)!)
      self.layoutIfNeeded()
    }
  }

  private func alphaStates(state: State) {
    switch state {
    case .centerRight:
      leftImageView.alpha = 1
      centerImageView.alpha = 1
      rightImageView.alpha = 0
      backImageView.alpha = 1
    case .centerCenter:
      leftImageView.alpha = 1
      centerImageView.alpha = 1
      rightImageView.alpha = 1
      backImageView.alpha = 0
    case .centerLeft:
      leftImageView.alpha = 0
      centerImageView.alpha = 1
      rightImageView.alpha = 1
      backImageView.alpha = 1
    case .centerBack:
      leftImageView.alpha = 1
      centerImageView.alpha = 0
      rightImageView.alpha = 1
      backImageView.alpha = 1
    }
  }

  private func setLeftItem(direction: ImageDirection, size: ImageSize) {
    leftWidth.constant = size.rawValue
    leftHeight.constant = size.rawValue
    leftCenterX.constant = direction.rawValue
  }

  private func setCenterItem(direction: ImageDirection, size: ImageSize) {
    centerWidth.constant = size.rawValue
    centerHeight.constant = size.rawValue
    centerCenterX.constant = direction.rawValue
  }

  private func setRightItem(direction: ImageDirection, size: ImageSize) {
    rightWidth.constant = size.rawValue
    rightHeight.constant = size.rawValue
    rightCenterX.constant = direction.rawValue
  }

  private func setBackItem(direction: ImageDirection, size: ImageSize) {
    backWidth.constant = size.rawValue
    backHeight.constant = size.rawValue
    backCenterX.constant = direction.rawValue
  }

  private func positionStates(state: State) {
    switch state {
    case .centerCenter:
      setLeftItem(direction: .left, size: .small)
      setCenterItem(direction: .center, size: .big)
      setRightItem(direction: .right, size: .small)
      setBackItem(direction: .center, size: .back)
    case .centerLeft:
      setLeftItem(direction: .center, size: .back)
      setCenterItem(direction: .left, size: .small)
      setRightItem(direction: .center, size: .big)
      setBackItem(direction: .right, size: .small)
    case .centerRight:
      setLeftItem(direction: .center, size: .big)
      setCenterItem(direction: .right, size: .small)
      setRightItem(direction: .center, size: .back)
      setBackItem(direction: .left, size: .small)
    case .centerBack:
      setLeftItem(direction: .right, size: .small)
      setCenterItem(direction: .center, size: .back)
      setRightItem(direction: .left, size: .small)
      setBackItem(direction: .center, size: .big)
    }
  }
}
