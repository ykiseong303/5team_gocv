//
//  DataManager.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 3..
//  Copyright © 2017년 busride. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import FirebaseDatabase

class DataManager{
    
    
    // 기본 데이터 레퍼런스
    static var ref : DatabaseReference! = Database.database().reference()
    
    /*
     * 메인화면
     */
    
    
    // 브랜드에 따라 리뷰 가져오고, 그걸 유용순으로 정리하기.
    static func getTop3ReviewByBrand(brand : String, completion: @escaping ([Review]) -> ()) {
        
        let localRef = ref.child("review")
        
        if brand == "전체" { // 브랜드 : 전체를 선택한 경우
            let query = localRef.queryOrdered(byChild: "useful").queryLimited(toLast: 3)
            query.observe(DataEventType.value, with: { (snapshot) in
                var reviewList : [Review]  = []
                for childSnapshot in snapshot.children {
                    let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                    reviewList.append(review)
                }
                reviewList = reviewList.sorted(by: { $0.useful > $1.useful })
                completion(reviewList)
            })

        }else { // 특정 브랜드를 선택한 경우
            let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
            
            query.observe(DataEventType.value, with: { (snapshot) in
                var reviewList : [Review]  = []
                for childSnapshot in snapshot.children {
                    let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                    reviewList.append(review)
                }
                reviewList = reviewList.sorted(by: { $0.useful > $1.useful })
                // 유용순으로 정렬하기
                completion(reviewList)
            })
            
        }
    }
    
    // 브랜드도 카테고리도 전체가 아닐 때
    // 카테고리로 받아와서 클라이언트에서 brand로 filter해주기 , 그리고 점수로 뿌려주기.
    static func getTopProductBy(brand : String, category : String, completion: @escaping ([Product]) -> ()) {
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var productList : [Product] = []
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                if product.brand == brand {
                    productList.append(product)
                }
                
            }
            // 가져온 상품를 평점 순으로 뿌려준다.
            productList.sorted(by: { $0.grade_avg > $1.grade_avg})
            completion(productList)
        })
    }
    
    
    // 브랜드만 달라지고 카테고리는 전체일 때
    static func getTopProductBy(brand : String, completion : @escaping ([Product]) -> ()) {
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var productList : [Product] = []
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                productList.append(product)
            }
            
            productList.sorted(by: { $0.grade_avg > $1.grade_avg})
            completion(productList)
        })
    }
    
    
    // 카테고리만 달라지고 브랜드는 전체일 때
    static func getTopProductBy(category: String, completion : @escaping ([Product]) -> ()) {
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var productList : [Product] = []
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                
                productList.append(product)
            }
            productList.sorted(by: { $0.grade_avg > $1.grade_avg})
            completion(productList)
        })
    }
    
    
    // 브랜드 + 카테고리 전체일 때
    static func getTop3Product(completion: @escaping ([Product]) -> ()) {
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "grade_avg").queryLimited(toLast: 3)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var productList : [Product] = []
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                productList.append(product)
            }
            completion(productList)
        })
    }
    
    /*
     * 리뷰 화면
     */
    
    // 브랜드와 카테고리가 전체가 아닐 때 리뷰 리스트 받아오기
    static func getReviewListBy(brand : String, category : String, completion : @escaping ([Review]) -> ()) {
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
        query.observe(DataEventType.value, with: { (snapshot) in
             var reviewList : [Review] = []
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                
                if review.category == category {
                    reviewList.append(review)
                }
            }
            
            completion(reviewList)
        })
    }
    
    // 카테고리가 전체일때 브랜드로만 리뷰 리스트 받아오기.
    static func getReviewListBy(brand: String, completion: @escaping ([Review]) ->()) {
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
        query.observe(DataEventType.value, with: { (snapshot) in
            var reviewList : [Review] = []
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                reviewList.append(review)
            }
            completion(reviewList)
        })
    }
    
    // 브랜드가 전체일때 카테고리로만 리뷰 리스트 받아오기.
    static func getReviewListBy(category: String, completion: @escaping ([Review]) ->()) {
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
        query.observe(DataEventType.value, with: { (snapshot) in
            var reviewList : [Review] = []
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                reviewList.append(review)
            }
            
            completion(reviewList)
        })
    }
    
    // 브랜드와 카테고리가 전체일 때 리뷰 리스트 받아오기.
    static func getReviewList(completion: @escaping ([Review]) ->()) {
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "useful")
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var reviewList : [Review] = []
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                reviewList.append(review)
            }
            completion(reviewList)
        })
    }
    
    // 상품 아이디로 리뷰 리스트 받아오기.
    static func getReviewListBy(id: String, completion: @escaping ([Review]) ->()) {
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "p_id").queryEqual(toValue: id)
        query.observe(DataEventType.value, with: { (snapshot) in
            var reviewList : [Review] = []
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                reviewList.append(review)
            }
            completion(reviewList)
        })
    }
    
    /*
     * 랭킹화면 : 메인화면 함수 재사용. 전체 브랜드 + 전체 카테고리 일 때 함수만 재작성.
     */
    
    static func getProductAllInRank(completion : @escaping ([Product]) -> ()){
        let localRef = ref.child("product")
        localRef.observe(DataEventType.value, with: { (snapshot) in
            var productList : [Product] = []
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot : childSnapshot as! DataSnapshot)
                productList.append(product)
            }

            completion(productList)
        })
    }
    
    // 상품 id로 상품 가져오기
    static func getProductById(id: String, completion : @escaping (Product) -> ()) {
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "id").queryEqual(toValue: id)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var product = Product()
            for childSnapshot in snapshot.children {
                product = Product.init(snapshot: childSnapshot as! DataSnapshot)
            }
            completion(product)
        })
    }
    
    
    /*
     *  리뷰 쓰기 화면
     */
    
    
    // 리뷰 쓰기
    static func writeReview(brand: String, category: String, grade: Int, priceLevel: Int, flavorLevel: Int, quantityLevel: Int, allergy: [String], review: String, user: String,user_image: String, p_id: String, p_image: UIImage, p_name: String, p_price: Int, completion: ()->()) {
        
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_kr")
        format.timeZone = TimeZone(abbreviation: "KST")
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let today = format.string(from: Date())
        var imgURL = ""
        
        let localRef = ref.child("review")
        let id = localRef.childByAutoId()
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference(forURL: "gs://pyeonrehae.appspot.com")
        let imagesRef = storageRef.child(id.description() + ".png")
        var update = ["bad": 0, "useful": 0, "user": user, "user_image": user_image, "brand": brand, "category": category, "comment": review, "grade": grade, "price": priceLevel, "flavor": flavorLevel, "quantity": quantityLevel, "p_id": p_id, "p_name": p_name, "p_price": p_price, "timestamp": today] as [String : Any]
        
        if let data = UIImagePNGRepresentation(p_image) {
            imagesRef.putData(data, metadata: nil, completion: {
                (metadata, error) in
                if error != nil {
                    update["p_image"] = imgURL
                    id.updateChildValues(update)
                    print(error!)
                } else {
                    imagesRef.downloadURL { (URL, error) -> Void in // 업로드된 이미지 url 받아오기
                        if (error != nil) { // 없으면 ""로 저장
                            update["p_image"] = imgURL
                            id.updateChildValues(update)
                            print(error!)
                        } else {
                            imgURL = (URL?.description)! // 있으면 해당 url로 저장
                            update["p_image"] = imgURL
                            id.updateChildValues(update)
                        }
                    }
                }
            })
        }
        completion()
    }
    
    /*
     * 검색 화면
     */
    
    // 상품 이름으로 상품아이디 가져오기 (겹치는 게 있을 시 처음 것)
    static func getProductId(from: String, completion : @escaping (String) -> ()){
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "name").queryEqual(toValue: from)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            var product = Product()
            for childSnapshot in snapshot.children {
                product = Product.init(snapshot: childSnapshot as! DataSnapshot)
            }
            completion(product.id)
        })
    }
}
