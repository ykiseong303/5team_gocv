export class DB {
    constructor(user, product, review) {
        this.user = user;
        this.product = product;
        this.review = review;
    }

    init() {
        const config = {
            apiKey: "AIzaSyAnDViQ2LyXlNzBWO2kWyGnN-Lr22B9sUI",
            authDomain: "pyeonrehae.firebaseapp.com",
            databaseURL: "https://pyeonrehae.firebaseio.com",
            projectId: "pyeonrehae",
            storageBucket: "pyeonrehae.appspot.com",
            messagingSenderId: "296270517036"
        };

        firebase.initializeApp(config);


        const value = {
            brand: 'all',
            category: '전체',
            keyword: ''
        };

        localStorage['search_keyword'] = JSON.stringify(value);

        this.updateUserDb();
        this.updateProductDb();
        this.updateReviewDb();

        this.user = JSON.parse(localStorage['user']);
        this.product = JSON.parse(localStorage['product']);
        this.review = JSON.parse(localStorage['review']);

    }

    updateDb(name){
        firebase.database().ref(name+'/').once('value').then(function (snapshot) {
            localStorage[name] = JSON.stringify(snapshot.val());
            this.user = JSON.parse(localStorage[name]);
            document.querySelector('#loading').style.display = "none"
            console.log(name+" 캐시 업데이트")
        }.bind(this));
    }

    updateAllDb(){
        this.updateDb("user");
        this.updateDb("review");
        this.updateDb("product");
    }

    updateUserDb(func) {
        firebase.database().ref('user/').once('value').then(function (snapshot) {
            localStorage['user'] = JSON.stringify(snapshot.val());
            this.user = JSON.parse(localStorage['user']);
            document.querySelector('#loading').style.display = "none"
            console.log("user 캐시 업데이트")

        }.bind(this));
    }

    updateReviewDb() {
        firebase.database().ref('review/').once('value').then(function (snapshot) {
            localStorage['review'] = JSON.stringify(snapshot.val());
            this.review = JSON.parse(localStorage['review']);
            document.querySelector('#loading').style.display = "none"
            console.log("review 캐시 업데이트")

        }.bind(this));
    }

    updateProductDb() {
        firebase.database().ref('product/').once('value').then(function (snapshot) {
            localStorage['product'] = JSON.stringify(snapshot.val());
            this.product = JSON.parse(localStorage['product']);
            document.querySelector('#loading').style.display = "none"
            console.log("product 캐시 업데이트")
        }.bind(this));
    }
}