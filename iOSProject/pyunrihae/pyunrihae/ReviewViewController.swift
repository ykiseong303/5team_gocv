//
//  ReviewViewController.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 7..
//  Copyright © 2017년 busride. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var reviewNumLabel: UILabel!
    @IBOutlet weak var sortingMethodLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedCategoryIndex: Int = 0 // 선택된 카테고리 인덱스, 초기값은 0 (전체)
    var categoryBtns = [UIButton]()
    let category = ["전체","도시락","김밥","베이커리","라면","즉석식품","스낵","유제품","음료"]
    func addCategoryBtn(){ // 카테고리 버튼 스크롤 뷰에 추가하기
        categoryScrollView.isScrollEnabled = true
        categoryScrollView.contentSize.width = CGFloat(80 * category.count)
        for index in 0..<category.count {
            let categoryBtn = UIButton(frame: CGRect(x: 80 * index, y: 5, width: 80, height: 40))
            categoryBtn.setTitle(category[index], for: .normal) // 카테고리 버튼 텍스트
            categoryBtn.setTitleColor(UIColor.darkGray, for: .normal) // 카테고리 버튼 텍스트 색깔
            categoryBtn.contentHorizontalAlignment = .center // 카테고리 버튼 중앙정렬
            categoryBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) // 카테고리 버튼 폰트 크기 15
            categoryBtn.tag = index // 버튼 태그 생성해주기
            categoryBtns.append(categoryBtn)
            categoryBtn.addTarget(self, action: #selector(didPressCategoryBtn), for: UIControlEvents.touchUpInside)
            categoryScrollView.addSubview(categoryBtn)
        }
        categoryScrollView.showsHorizontalScrollIndicator = false // 스크롤 바 없애기
    }
    func didPressCategoryBtn(sender: UIButton) { // 카테고리 버튼 클릭 함수
        let previousCategoryIndex = selectedCategoryIndex
        selectedCategoryIndex = sender.tag
        categoryBtns[previousCategoryIndex].isSelected = false
        Button.select(btn: sender) // 선택된 버튼에 따라 뷰 보여주기
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        categoryScrollView.backgroundColor = UIColor.white
        addCategoryBtn() // 카테고리 버튼 만들어서 스크롤 뷰에 붙이기
        Button.select(btn: categoryBtns[selectedCategoryIndex]) // 맨 처음 카테고리는 전체 선택된 것으로 나타나게 함
        didPressCategoryBtn(sender: categoryBtns[selectedCategoryIndex])

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ReviewViewController: UICollectionViewDataSource { //메인화면에서 1,2,3위 상품 보여주기
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ReviewCollectionViewCell {
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
            cell.userImage.clipsToBounds = true
            //임의로 유저 사진 넣어놨음
                cell.userImage.image = UIImage(named: "search.png")
                cell.userImage.backgroundColor = UIColor.lightGray
            //
            //임의의 별점
            let grade = 3.6
            //
            for i in 0..<Int(grade) {
                let starImage = UIImage(named: "stars.png")
                let cgImage = starImage?.cgImage
                let croppedCGImage: CGImage = cgImage!.cropping(to: CGRect(x: 0, y: 0, width: (starImage?.size.width)! / 5, height: starImage!.size.height))!
                let uiImage = UIImage(cgImage: croppedCGImage)
                let imageView = UIImageView(image: uiImage)
                imageView.frame = CGRect(x: i*18, y: 0, width: 18, height: 15)
                cell.starView.addSubview(imageView)
            }
            if grade - Double(Int(grade)) >= 0.5 {
                let starImage = UIImage(named: "stars.png")
                let cgImage = starImage?.cgImage
                let croppedCGImage: CGImage = cgImage!.cropping(to: CGRect(x: (starImage?.size.width)! * 4 / 5, y: 0, width: (starImage?.size.width)!, height: starImage!.size.height))!
                let uiImage = UIImage(cgImage: croppedCGImage)
                let imageView = UIImageView(image: uiImage)
                imageView.frame = CGRect(x: Int(grade)*18 - 3, y: 0, width: 18, height: 15)
                cell.starView.addSubview(imageView)
            }
            cell.reviewView.layer.cornerRadius = 15
            cell.userImage.clipsToBounds = true
            return cell
        }
        return ReviewCollectionViewCell()
    }
}
extension ReviewViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
}

