//
//  ViewController.swift
//  TrioCarouselExample
//
//  Created by Yilmaz Edis on 13.09.2023.
//

import UIKit

class ViewController: UIViewController {

  let images = [UIImage(named: "image_1")!, UIImage(named: "image_2")!, UIImage(named: "image_3")!,
                UIImage(named: "image_4")!, UIImage(named: "image_5")!, UIImage(named: "image_6")!,
                UIImage(named: "image_7")!, UIImage(named: "image_8")!, UIImage(named: "image_9")!,
                UIImage(named: "image_10")!]

  var titles: [String] = []

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var trioCarouselView: TrioCarouselView!
  @IBOutlet weak var selectionTitle: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    for i in 1...10 {
      let imageName = "image_\(i)"
      titles.append(imageName)
    }

    trioCarouselView.delegate = self
    trioCarouselView.configure(images: images)
    trioCarouselView.setCornerRadius(16)
  }


  @IBAction func updateImageNumberAction(_ sender: UIButton) {
    switch sender.tag {
    case 0:
      trioCarouselView.configure(images: [])
    case 1:
      trioCarouselView.configure(images: Array(images.prefix(1)))
    case 2:
      trioCarouselView.configure(images: Array(images.prefix(2)))
    case 3:
      trioCarouselView.configure(images: Array(images.prefix(3)))
    case 4:
      trioCarouselView.configure(images: Array(images.prefix(4)))
    case 10:
      trioCarouselView.configure(images: images)
    default:
      break
    }
  }
}

extension ViewController: TrioCarouselViewDelegate {
  func TrioCarouselView(didSelect index: Int) {
    selectionTitle.text = "\(titles[index]) is selected"
    print(index)
  }

  func TrioCarouselView(imageForCenterAt index: Int) {
    titleLabel.text = titles[index]
    print(index)
  }
}

