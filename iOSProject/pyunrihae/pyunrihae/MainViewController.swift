//
//  MainViewController.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 4..
//  Copyright © 2017년 busride. All rights reserved.
//
import UIKit
class MainViewController: UIViewController {
    @IBOutlet weak var reviewScrollView: UIScrollView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var productScrollView: UIScrollView!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var productList : [Product] = []
    var reviewList : [Review] = []
    var review = Review()
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var categoryBtns = [UIButton]()
    var scrollBar = UILabel()
    var usefulNumLabel = UILabel()
    var badNumLabel = UILabel()
    var usefulBtn = UIButton()
    var badBtn = UIButton()
    var selectedReview = Review()
    var selectedBrandIndexFromTab : Int = 0 {
        didSet{
            getProductList()
            setReviewScrollImages()
        }
    }
    var selectedCategoryIndex: Int = 0 { // 선택된 카테고리 인덱스, 초기값은 0 (전체)
        didSet{
            getProductList()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(getProductList), name: NSNotification.Name("productListChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectCategory), name: NSNotification.Name("selectCategory"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDetailProduct), name: NSNotification.Name("showDetailProduct"), object: nil)
        categoryScrollView.backgroundColor = UIColor.white
        addCategoryBtn() // 카테고리 버튼 만들어서 스크롤 뷰에 붙이기
        Button.select(btn: categoryBtns[selectedCategoryIndex]) // 맨 처음 카테고리는 전체 선택된 것으로 나타나게 함
        didPressCategoryBtn(sender: categoryBtns[selectedCategoryIndex])
        reviewScrollView.backgroundColor = UIColor.lightGray
        reviewScrollView.isPagingEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.reviewScrollView.addGestureRecognizer(tap)
        self.reviewScrollView.isUserInteractionEnabled = true
        DataManager.getTop3Product() { (products) in
            self.productList = products
            DispatchQueue.main.async {
//                self.collectionView.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showDetailProduct(_ notification: Notification) {
        if notification.userInfo?["validator"] as! Int == 0{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainNavigationController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
            print(review.p_id)
            NotificationCenter.default.post(name: NSNotification.Name("showReviewProduct"), object: self, userInfo: ["product" : review])
        }
    }
    // 카테고리 버튼 스크롤 뷰에 추가하기
    func addCategoryBtn(){
        categoryBtns = Button.addCategoryBtn(view: self.view, categoryScrollView: categoryScrollView, category: appdelegate.category, scrollBar: scrollBar)
        for i in 0..<categoryBtns.count {
            categoryBtns[i].addTarget(self, action: #selector(didPressCategoryBtn), for: UIControlEvents.touchUpInside)
        }
    }
    // 카테고리 버튼 클릭 이벤트 함수
    func didPressCategoryBtn(sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,animations: {
            Button.selectCategory(view: self.view, previousIndex: self.selectedCategoryIndex, categoryBtns: self.categoryBtns, selectedCategoryIndex: sender.tag, categoryScrollView: self.categoryScrollView, scrollBar: self.scrollBar)
            self.selectedCategoryIndex = sender.tag
        },completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name("showCategory"), object: self, userInfo: ["category" : selectedCategoryIndex])
    }
    // 카테고리를 선택했을 때 함수
    func selectCategory(_ notification: Notification){
        Button.selectCategory(view: self.view, previousIndex: selectedCategoryIndex, categoryBtns: categoryBtns, selectedCategoryIndex: notification.userInfo?["category"] as! Int, categoryScrollView: categoryScrollView, scrollBar: scrollBar)
        selectedCategoryIndex = notification.userInfo?["category"] as! Int
    }
    // 로딩 인디케이터 보이는 함수 DEPRECATED
    func showActivityIndicatory() {
        self.actInd.frame = CGRect.init(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        self.actInd.center = view.superview?.center ?? view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(actInd)
        actInd.startAnimating()
    }
    // 로딩 인디케이터 숨기는 함수 DEPRECATED
    func hideActivityIndicatory() {
        if view.subviews.contains(actInd){
            actInd.stopAnimating()
            view.willRemoveSubview(actInd)
        }
    }
    // productList를 받아오는 함수
    func getProductList(){
        var brand = ""
        switch selectedBrandIndexFromTab {
        case 0 : brand = ""
        case 1 : brand = "GS25"
        case 2 : brand = "CU"
        case 3 : brand = "7-eleven"
        default : break
        }
        self.showActivityIndicatory()
        if selectedBrandIndexFromTab == 0  && selectedCategoryIndex == 0 { // 브랜드 : 전체 , 카테고리 : 전체 일때
            if self.appdelegate.productList.count > 0 { // global product list가 저장된 후
                self.productList = self.appdelegate.productList
                DispatchQueue.main.async {
                    self.setProductScrollView()
                    self.hideActivityIndicatory()
                }
            }else{ // global product list가 없다면
                DataManager.getTop3Product() { (products) in
                    self.productList = products
                    DispatchQueue.main.async {
                        self.setProductScrollView()
                        self.hideActivityIndicatory()
                    }
                }
            }
        } else if selectedBrandIndexFromTab == 0 { // 브랜드만 전체일 때
            if categoryBtns.count > 0 {
                self.productList = []
                for product in self.appdelegate.productList {
                    if product.category == categoryBtns[selectedCategoryIndex].titleLabel?.text!{
                         self.productList.append(product)
                    }
                }
                DispatchQueue.main.async {
                    self.setProductScrollView()
                    self.hideActivityIndicatory()
                }
            }
        } else if selectedCategoryIndex == 0 { // 카테고리만 전체일 때
            self.productList = []
            for product in self.appdelegate.productList {
                if product.brand == brand{
                    self.productList.append(product)
                }
            }
            DispatchQueue.main.async {
                self.setProductScrollView()
                self.hideActivityIndicatory()
            }
        } else { // 브랜드도 카테고리도 전체가 아닐 때
            if categoryBtns.count > 0 {
                self.productList = []
                for product in self.appdelegate.productList {
                    if product.brand == brand && product.category == categoryBtns[selectedCategoryIndex].titleLabel?.text!{
                        self.productList.append(product)
                    }
                }
                DispatchQueue.main.async {
                    self.setProductScrollView()
                    self.hideActivityIndicatory()
                }
            }
        }
    }
    // 리뷰의 스크롤 이미지를 가져오는 함수
    func setReviewScrollImages(){
        var brand = ""
        switch selectedBrandIndexFromTab {
            case 0 : brand = "전체"
            case 1 : brand = "GS25"
            case 2 : brand = "CU"
            case 3 : brand = "7-eleven"
            default : break
        }
//        indicatorView.startAnimating()
        DataManager.getTop3ReviewByBrand(brand: brand) { (reviews) in
            self.reviewList = reviews
            if self.reviewScrollView != nil {
                let imageViewWidth = self.reviewScrollView.frame.size.width;
                let imageViewHeight = self.reviewScrollView.frame.size.height;
                var xPosition:CGFloat = 0;
                var scrollViewSize:CGFloat=0
                var cnt = 0
                let scrollViewImageNum = 3
                self.reviewScrollView.contentSize = CGSize(width: imageViewWidth*CGFloat(3), height: imageViewHeight)
                for review in self.reviewList {
                    if cnt >= scrollViewImageNum {
                        break
                    }
                    let url = URL(string: review.p_image)
                    let reviewView = MainReviewView.instanceFromNib()
                    reviewView.translatesAutoresizingMaskIntoConstraints = true
                    reviewView.frame = CGRect(x: xPosition, y: 0, width: imageViewWidth, height: imageViewHeight)
                    let myImageView = reviewView.myImageView
                    let brandLabel =  reviewView.brandLabel
                    let nameLabel =  reviewView.nameLabel
                    let reviewLabel = reviewView.reviewLabel
                    let hotReviewLabel = reviewView.hotReviewLabel
                    let selectedCountLabel = reviewView.selectedCountLabel
                    let totalCountLabel = reviewView.totalCountLabel
                    let starImageView = reviewView.starImageView
                    // 기본이미지 있어야함
                    if url != nil {
                        myImageView?.af_setImage(withURL: url!)
                    }else{
                        myImageView?.af_setImage(withURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/pyeonrehae.appspot.com/o/ic_background_default.png?alt=media&token=09d05950-5f8a-4a73-95b3-a74faee4cad3")!)
                    }
                    myImageView?.contentMode = UIViewContentMode.scaleAspectFill
                    brandLabel?.text = review.brand
                    nameLabel?.text = review.p_name
                    if imageViewWidth < 375 {
                        hotReviewLabel?.layer.cornerRadius = 12
                    }else if imageViewWidth > 1024{
                        hotReviewLabel?.layer.cornerRadius = 20
                    }else{
                         hotReviewLabel?.layer.cornerRadius = 14
                    }
                    hotReviewLabel?.layer.masksToBounds = true
                    hotReviewLabel?.clipsToBounds = true
                    //리뷰를 줄간격을 16 + 글자색 흰색으로 바꾸는 코드
                    let style = NSMutableParagraphStyle()
                    let attrString = NSMutableAttributedString(string: review.comment)
                    style.minimumLineHeight = (reviewLabel?.font.pointSize)! * 1.6
                    attrString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: review.comment.characters.count))
                    attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white , range: NSRange(location: 0, length: review.comment.characters.count))
                    reviewLabel?.attributedText = attrString
                    selectedCountLabel?.text = (cnt + 1).description
                    totalCountLabel?.text = scrollViewImageNum.description
                    switch(review.grade) {
                        case 1 : starImageView?.image = #imageLiteral(resourceName: "star1.png")
                        case 2: starImageView?.image = #imageLiteral(resourceName: "star2.png")
                        case 3 : starImageView?.image = #imageLiteral(resourceName: "star3.png")
                        case 4 : starImageView?.image = #imageLiteral(resourceName: "star4.png")
                        case 5 : starImageView?.image = #imageLiteral(resourceName: "star5.png")
                        default : starImageView?.image = #imageLiteral(resourceName: "star3.png")
                    }
                    self.reviewScrollView.addSubview(reviewView)
                    xPosition += imageViewWidth
                    scrollViewSize += imageViewWidth
                    cnt = cnt + 1
                }
            }
        }
    }
    func setProductScrollView(){
        for subview in self.productScrollView.subviews {
            subview.removeFromSuperview()
        }
        if self.productScrollView != nil {
            let imageViewWidth = self.productScrollView.frame.size.width;
            let imageViewHeight = self.productScrollView.frame.size.height;
            var xPosition:CGFloat = 0;
            var cnt = 0
            let scrollViewNum = 10
            self.productScrollView.contentSize = CGSize(width: imageViewWidth / 3.0 * CGFloat(scrollViewNum), height: imageViewHeight);
            for product in productList {
                if cnt >= scrollViewNum {
                    break;
                }
                let url = URL(string: product.image)
                let productView = MainProduct.instanceFromNib()
                productView.translatesAutoresizingMaskIntoConstraints = true
                productView.frame = CGRect(x: xPosition, y: 0, width: imageViewWidth / 3.0, height: imageViewWidth / 3.0)
                productView.center.y = imageViewHeight / 2.0
                // productView들어감
                productView.productImageview.contentMode = .scaleAspectFit
                productView.productImageview.af_setImage(withURL: url!)
                productView.rankLabel.text = (cnt + 1).description
                switch (product.brand) {
                    case "GS25": productView.logoImageView.image = #imageLiteral(resourceName: "logo_gs25.png")
                    case "7-eleven": productView.logoImageView.image = #imageLiteral(resourceName: "logo_7eleven.png")
                    case "CU": productView.logoImageView.image = #imageLiteral(resourceName: "logo_cu.png")
                    default : productView.logoImageView.image = #imageLiteral(resourceName: "ic_common.png")
                }
                productView.nameLabel.text = product.name
                productView.tag = cnt
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.showProduct(_:)))
                productView.addGestureRecognizer(tap)
                productView.isUserInteractionEnabled = true
                self.productScrollView.addSubview(productView)
                xPosition += imageViewWidth / 3.0
                cnt = cnt + 1
            }
        }
    }
    // 리뷰 스크롤을 눌렀을 때 전환하는 함수
    func handleTap(_ sender: UITapGestureRecognizer) {
        let popup: ReviewPopupView = UINib(nibName: "ReviewPopupView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ReviewPopupView
        popup.validator = 0
        var index = 0
        if reviewScrollView.contentOffset.x != 0{
            index = 2 - Int(reviewScrollView.frame.width / reviewScrollView.contentOffset.x)
        }


        review = reviewList[index]
        selectedReview = review
        let frame = self.view.frame
        popup.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        popup.frame = frame
        popup.view.layer.borderColor = UIColor.gray.cgColor
        popup.view.layer.borderWidth = 0.3
        popup.view.layer.cornerRadius = 10
        popup.view.layer.cornerRadius = 10
        popup.badNumLabel.text = String(review.bad)
        popup.usefulNumLabel.text = String(review.useful)
        popup.comment.text = review.comment
        popup.comment.isEditable = false
        popup.comment.layer.cornerRadius = 10
        popup.comment.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        popup.userNameLabel.text = review.user
        popup.foodNameLabel.text = review.p_name
        self.view.addSubview(popup)
        Image.makeCircleImage(image: popup.userImage)
        popup.userImage.contentMode = .scaleAspectFit
        popup.userImage.layer.borderColor = UIColor.gray.cgColor
        popup.userImage.layer.borderWidth = 0.3
        usefulNumLabel = popup.usefulNumLabel
        badNumLabel = popup.badNumLabel
        usefulBtn = popup.usefulBtn
        badBtn = popup.badBtn
        if let userReviewLike = appdelegate.user?.review_like_list[review.id]{
            if userReviewLike == 1 {
                Button.makeBorder(btn: usefulBtn)
                Button.deleteBorder(btn: badBtn)
                usefulNumLabel.textColor = UIColor.red
                badNumLabel.textColor = UIColor.lightGray
            } else if userReviewLike == -1 {
                Button.makeBorder(btn: badBtn)
                Button.deleteBorder(btn: usefulBtn)
                usefulNumLabel.textColor = UIColor.lightGray
                badNumLabel.textColor = UIColor.red
            } else {
                Button.deleteBorder(btn: usefulBtn)
                Button.deleteBorder(btn: badBtn)
                usefulNumLabel.textColor = UIColor.lightGray
                badNumLabel.textColor = UIColor.lightGray
            }
        } else {
            Button.deleteBorder(btn: usefulBtn)
            Button.deleteBorder(btn: badBtn)
            usefulNumLabel.textColor = UIColor.lightGray
            badNumLabel.textColor = UIColor.lightGray
        }
        popup.badBtn.addTarget(self, action: #selector(self.didPressBadBtn), for: UIControlEvents.touchUpInside)
        popup.usefulBtn.addTarget(self, action: #selector(self.didPressUsefulBtn), for: UIControlEvents.touchUpInside)

        // 카카오톡 공유 버튼 누르기
        popup.kakaoShareBtn.addTarget(self, action: #selector(self.didPressKakaoShareBtn), for: UIControlEvents.touchUpInside)


        if URL(string: review.user_image) != nil{
            popup.userImage.af_setImage(withURL: URL(string: review.user_image)!)
        } else {
            popup.userImage.image = UIImage(named: "user_default.png")
        }
        popup.uploadedImage.contentMode = .scaleAspectFill
        popup.uploadedImage.clipsToBounds = true
        if URL(string: review.p_image) != nil{
            popup.uploadedImage.af_setImage(withURL: URL(string: review.p_image)!)
        } else {
            popup.uploadedImage.af_setImage(withURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/pyeonrehae.appspot.com/o/ic_background_default.png?alt=media&token=09d05950-5f8a-4a73-95b3-a74faee4cad3")!)
        }
        popup.brand.contentMode = .scaleAspectFit
        if review.brand == "CU" {
            popup.brand.image = UIImage(named: "logo_cu.png")
        } else if review.brand == "GS25" {
            popup.brand.image = UIImage(named: "logo_gs25.png")
        } else if review.brand == "7-eleven" {
            popup.brand.image = UIImage(named: "logo_7eleven.png")
        } else {
            popup.brand.image = UIImage(named: "ic_common.png")
        }
        switch(review.grade) {
        case 1 : popup.starView.image = #imageLiteral(resourceName: "star1.png");
        case 2: popup.starView.image = #imageLiteral(resourceName: "star2.png");
        case 3 : popup.starView.image = #imageLiteral(resourceName: "star3.png");
        case 4 : popup.starView.image = #imageLiteral(resourceName: "star4.png");
        case 5 : popup.starView.image = #imageLiteral(resourceName: "star5.png");
        default : popup.starView.image = #imageLiteral(resourceName: "star3.png");
        }
        popup.starView.contentMode = .scaleAspectFit

        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_kr")
        format.timeZone = TimeZone(abbreviation: "KST")
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let writtenDate = format.date(from: review.timestamp) {
            if writtenDate.timeIntervalSinceNow >= -5 * 24 * 60 * 60 {
                if writtenDate.timeIntervalSinceNow <= -1 * 24 * 60 * 60 {
                    let daysAgo = Int(-writtenDate.timeIntervalSinceNow / 24 / 60 / 60)
                    popup.timeLabel.text = String(daysAgo) + "일 전"
                } else if writtenDate.timeIntervalSinceNow <= -1 * 60 * 60 {
                    let hoursAgo = Int(-writtenDate.timeIntervalSinceNow / 60 / 60)
                    popup.timeLabel.text = String(hoursAgo) + "시간 전"
                } else if writtenDate.timeIntervalSinceNow <= -1 * 60{
                    let minutesAgo = Int(-writtenDate.timeIntervalSinceNow / 60)
                    popup.timeLabel.text = String(minutesAgo) + "분 전"
                } else{
                    popup.timeLabel.text = "방금"
                }
            } else {
                popup.timeLabel.text = review.timestamp.components(separatedBy: " ")[0]
            }
        }
    }
    func didPressUsefulBtn(sender: UIButton) { //유용해요 버튼 누르기
        if appdelegate.user?.email == "" {
            let alert = UIAlertController(title: "로그인 후 이용해주세요!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            Button.didPressUsefulBtn(sender: sender, reviewId: review.id, usefulNumLabel: usefulNumLabel, badNumLabel: badNumLabel, usefulBtn: usefulBtn, badBtn: badBtn, reviewList: reviewList)
        }
    }
    func didPressBadBtn(sender: UIButton) { //별로에요 버튼 누르기
        if appdelegate.user?.email == "" {
            let alert = UIAlertController(title: "로그인 후 이용해주세요!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            Button.didPressBadBtn(sender: sender, reviewId: review.id, usefulNumLabel: usefulNumLabel, badNumLabel: badNumLabel, usefulBtn: usefulBtn, badBtn: badBtn, reviewList: reviewList)
        }
    }
    func didPressKakaoShareBtn(sender: UIButton) { //카카오톡 공유 버튼 클릭 이벤트
        DataManager.sendLinkFeed(review: selectedReview)
    }
     // 상품을 눌렀을 때 상세를 보여주는 함수
    func showProduct(_ sender: UITapGestureRecognizer) {
        if productList.count > 0 {
            let product = productList[(sender.view?.tag)!]
            NotificationCenter.default.post(name: NSNotification.Name("showProduct"), object: self, userInfo: ["product" : product])
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainNavigationController") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }
    }
}
