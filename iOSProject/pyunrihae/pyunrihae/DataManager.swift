//
//  DataManager.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 3..
//  Copyright © 2017년 busride. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DataManager{
    
    
    // 기본 데이터 레퍼런스
    static var ref : DatabaseReference! = Database.database().reference()
    
    
    // 브랜드에 따라 리뷰 가져오고, 그걸 유용순으로 정리하기.
    static func getTop3ReviewByBrand(brand : String, completion: @escaping ([Review]) -> ()) {
        var reviewList : [Review]  = []
        
        let localRef = ref.child("review")
        let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            
            for childSnapshot in snapshot.children {
                let review = Review.init(snapshot: childSnapshot as! DataSnapshot)
                reviewList.append(review)
            }
            reviewList.sorted(by: { $0.useful > $1.useful })
            // 유용순으로 정렬하기
            completion(reviewList)
        })
    }
    
    // 브랜드도 카테고리도 전체가 아닐 때
    // 카테고리로 받아와서 클라이언트에서 brand로 filter해주기 , 그리고 점수로 뿌려주기.
    static func getTop3ProductBy(brand : String, category : String, completion: @escaping ([Product]) -> ()) {
        var productList : [Product] = []
        
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            
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
    static func getTop3ProductBy(brand : String, completion : @escaping ([Product]) -> ()) {
        var productList : [Product] = []
        
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "brand").queryEqual(toValue: brand)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                productList.append(product)
            }
            
            productList.sorted(by: { $0.grade_avg > $1.grade_avg})
            completion(productList)
        })
    }
    
    
    // 카테고리만 달라지고 브랜드는 전체일 때
    static func getTop3ProductBy(category: String, completion : @escaping ([Product]) -> ()) {
        var productList : [Product] = []
        
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            
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
    
        var productList : [Product] = []
        
        let localRef = ref.child("product")
        let query = localRef.queryOrdered(byChild: "grade_avg").queryLimited(toLast: 3)
        
        query.observe(DataEventType.value, with: { (snapshot) in
            
            for childSnapshot in snapshot.children {
                let product = Product.init(snapshot: childSnapshot as! DataSnapshot)
                productList.append(product)
            }
            completion(productList)
        })
    }
}
