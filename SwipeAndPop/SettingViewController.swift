//
//  SettingViewController.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 20.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FBSDKLoginKit
import SpriteKit


class SettingViewController: UIViewController {
    
    //MARK: settingLock
    
    let userRef = Database.database().reference(withPath: "UserLevelAndScore")
    
    var levelCount = 0
    var arrLevels:[Int] = []
    
    @IBOutlet weak var lockLevel2: UIImageView!
    @IBOutlet weak var lockLevel3: UIImageView!
    @IBOutlet weak var lockLevel4: UIImageView!
    @IBOutlet weak var lockLevel5: UIImageView!
    @IBOutlet weak var lockLevel6: UIImageView!
    
    @IBOutlet weak var viewLevel1: UIView!
    @IBOutlet weak var viewLevel2: UIView!
    @IBOutlet weak var viewLevel3: UIView!
    @IBOutlet weak var viewLevel4: UIView!
    @IBOutlet weak var viewLevel5: UIView!
    @IBOutlet weak var viewLevel6: UIView!
    
    @IBOutlet weak var backToGame: UIButton!
    
    @IBOutlet weak var instrucBubble: UIImageView!
    
    @IBOutlet weak var signOut: UIButton!
    
    
    var scene: GameScene!
    var oldSet:Set<Character>!
    
    var numLevelReturn = 0
    var moveleftBack = 0
    var scoreBack = 0
    
    var game: GameViewController!
    var level: Level!
    
    var viewLevel:Bool = true
    
    var user:User!
    
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func returnToGameBtn(_ sender: UIButton) {
        // print("@@@@###\(dataUser.first)")
        performSegue(withIdentifier: "backToGame", sender: user)
        
    }
    
    
    var dataUser = [UserScoreData]()
    
    fileprivate func prepareLayers() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        
        noteView.layer.cornerRadius = 10
        
        
        styleLockView(view: viewLevel1)
        styleLockView(view: viewLevel2)
        styleLockView(view: viewLevel3)
        styleLockView(view: viewLevel4)
        styleLockView(view: viewLevel5)
        styleLockView(view: viewLevel6)
    }
    
    var images:[UIImage] = []
    var timer = Timer()
    var photoCount:Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        if screenWidth < 325{
    
            signOut.transform = CGAffineTransform(translationX: -40, y: 45).scaledBy(x: 0.5, y: 0.5)
            backToGame.transform = CGAffineTransform(translationX: 5, y: 15).scaledBy(x: 0.75, y: 0.75)
            instrucBubble.transform = CGAffineTransform(translationX: 20, y: 45).scaledBy(x: 0.5, y: 0.5)

        }
        
        
        ///////////////
        images = [#imageLiteral(resourceName: "monkeySpeak"), #imageLiteral(resourceName: "monkeySpeak3"),#imageLiteral(resourceName: "monkeySpeak2"), #imageLiteral(resourceName: "monkeySpeak4"), #imageLiteral(resourceName: "monkeySpeak6")]
        backToGame.setImage(images[0], for: .normal)
        //backToGame.image = UIImage.init(named: images[0])
        
         timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(onTransition), userInfo: nil, repeats: true)

        
      
//        UIView.transition(with: backToGame, duration: 1, options: .repeat, animations: {
//                self.backToGame.setImage(#imageLiteral(resourceName: "monkeySpeak2"), for: .highlighted)
//
//        }, completion: nil)
        
       
        
//        let userID = Auth.auth().currentUser?.uid
//
//        Database.database().reference(withPath: "UserLevelAndScore").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let json = snapshot.value as! [String: Any]
//
//            self.levelCount = Int(snapshot.childrenCount)
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
        print("+++++++++++++++++++++++++++")
        print(levelCount)
      
        
        
        addToLevelViewTapGest(level: levelCount)
        
        
        prepareLayers()
        
        //readDataFromFirebase()
    
        
        
        
        
        user = Auth.auth().currentUser
        
        
        profileImage.sd_setImage(with: user.photoURL, placeholderImage: UIImage(named: "anonymousImage")!)
        
        var emailName = user.email
        var name = user.displayName
        emailName?.removeLast(10)
        if user.isAnonymous{
            name = "Guest"
            emailName = "anonymous"
        }
        nameLabel.text = name ?? emailName
        
        guard (scoreLabel) != nil else {
            scoreLabel.text = "Score: 0"
            return
        }
        scoreLabel.text = "Score: \(scoreBack)"
        
        
        
        
//        userRef.observe(.childAdded, with: { (snapShot) in
//            let json = snapShot.value as! [String: Any]
//            let dataGame = UserScoreData(json: json)
//            self.dataUser.append(dataGame)
//        })
//
        
        
        
        
    }
    var count = 0
    @objc func onTransition() {
        if (photoCount < images.count - 1){
            photoCount = photoCount  + 1;
        }else{
            photoCount = 0;
        }
        if count >= 10{
            timer.invalidate()
        }
        UIView.transition(with: self.backToGame, duration: 0.3, options: .curveEaseInOut, animations: {
            self.backToGame.setImage(self.images[self.photoCount], for: .normal)
        }, completion: nil)
        
        count += 1
        
        
    }
    
    typealias LevelArrayClosure = (Array<Int>?) -> Void
    
    func loadFromFireBase(completionHandler:@escaping LevelArrayClosure) {
        userRef.observe(.value, with: { snapshot in
            var songArray:Array<Int> = []
            //Put code here to load songArray from the FireBase returned data
            songArray.append(Int(snapshot.childrenCount))
            //Pass songArray to the completion handler on the main thread.
            DispatchQueue.main.async() {
                if songArray.isEmpty {
                    completionHandler(nil)
                }else {
                    completionHandler(songArray)
                    self.levelCount = songArray.first!
                }
            }
        })
    }
    
    

    func addToLevelViewTapGest(level:Int) {
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
         let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
         let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
         let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
         let tapGestureRecognizer5 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
         let tapGestureRecognizer6 = UITapGestureRecognizer(target: self, action: #selector(handleTapGest))
        
        
        self.viewLevel1.addGestureRecognizer(tapGestureRecognizer1)
        self.viewLevel1.tag = 1
        self.viewLevel2.tag = 2
        self.viewLevel3.tag = 3
        self.viewLevel4.tag = 4
        self.viewLevel5.tag = 5
        self.viewLevel6.tag = 6
        
        switch level {
        case 2:
            lockLevel2.isHidden = true
            self.viewLevel2.addGestureRecognizer(tapGestureRecognizer2)
            
        case 3:
            lockLevel2.isHidden = true
            lockLevel3.isHidden = true
            self.viewLevel2.addGestureRecognizer(tapGestureRecognizer2)
            self.viewLevel3.addGestureRecognizer(tapGestureRecognizer3)
            
        case 4:
            lockLevel2.isHidden = true
            lockLevel3.isHidden = true
            lockLevel4.isHidden = true
            self.viewLevel2.addGestureRecognizer(tapGestureRecognizer2)
            self.viewLevel3.addGestureRecognizer(tapGestureRecognizer3)
            self.viewLevel4.addGestureRecognizer(tapGestureRecognizer4)
        case 5:
            lockLevel2.isHidden = true
            lockLevel3.isHidden = true
            lockLevel4.isHidden = true
            lockLevel5.isHidden = true
            self.viewLevel2.addGestureRecognizer(tapGestureRecognizer2)
            self.viewLevel3.addGestureRecognizer(tapGestureRecognizer3)
            self.viewLevel4.addGestureRecognizer(tapGestureRecognizer4)
            self.viewLevel5.addGestureRecognizer(tapGestureRecognizer5)
        case 6:
            lockLevel2.isHidden = true
            lockLevel3.isHidden = true
            lockLevel4.isHidden = true
            lockLevel5.isHidden = true
            lockLevel6.isHidden = true
            self.viewLevel2.addGestureRecognizer(tapGestureRecognizer2)
            self.viewLevel3.addGestureRecognizer(tapGestureRecognizer3)
            self.viewLevel4.addGestureRecognizer(tapGestureRecognizer4)
            self.viewLevel5.addGestureRecognizer(tapGestureRecognizer5)
            self.viewLevel6.addGestureRecognizer(tapGestureRecognizer6)
            
        default:
            lockLevel2.isHidden = false
            lockLevel3.isHidden = false
            lockLevel4.isHidden = false
            lockLevel5.isHidden = false
            lockLevel6.isHidden = false
        }
        
        
    }
    @objc func handleTapGest(sender: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: "backToGame", sender: sender)
        
    }
    
    @IBAction func signOutButton(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            FBSDKLoginManager().logOut()
            performSegue(withIdentifier: "backToLogin", sender: sender)
            
        }
        catch let error{
            print("error type: +++ \(error)")
        }
        
        
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func styleLockView(view: UIView)  {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.brown.cgColor
    }
    
    
    
    func readDataFromFirebase(){
        
        let userID = Auth.auth().currentUser?.uid
        
        
        
       var db = Database.database().reference(withPath: "UserLevelAndScore").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let json = snapshot.value as! [String: Any]
            print("😎Here THE USER DATA: \(json)")
            print("😎child count: \(snapshot.childrenCount)")
            
            self.levelCount = Int(snapshot.childrenCount)
            self.arrLevels.append(self.levelCount)
        
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? GameViewController{
            if  let s = sender as? UITapGestureRecognizer{
    
                guard let tag = s.view?.tag else{return}
                print("🐱\(tag)")
                
                switch tag{
                case 1:
                    dest.levelNum = 1
                   dest.setupLevel(1)
                case 2:
                    dest.levelNum = 2
                    dest.setupLevel(2)
                    print("🐶\(tag)")
                case 3:
                    dest.levelNum = 3
                    dest.setupLevel(3)
                case 4:
                    dest.levelNum = 4
                    dest.setupLevel(4)
                case 5:
                    dest.levelNum = 5
                    dest.setupLevel(5)
                case 6:
                    dest.levelNum = 6
                    dest.setupLevel(6)
                default:
                    dest.levelNum = 1
                    dest.setupLevel(1)
                }
                
                //dest.levelNum = tag
               
                
                
//                let userID = Auth.auth().currentUser?.uid
//                Database.database().reference(withPath: "UserLevelAndScore").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//                    // Get user value
//                    let json = snapshot.value as! [String: Any]
//                    print("😎Here THE USER DATA: \(json)")
//                    print("😎child count: \(snapshot.childrenCount)")
//
//                    dest.setupLevel(Int(snapshot.childrenCount))
//
//                    // ...
//                }) { (error) in
//                    print(error.localizedDescription)
//                }
//                var i = readDataFromFirebase()
//                print("🐶\(i)")
//                dest.setupLevel(i)
                
            }else{
                
                dest.levelNum = numLevelReturn
                dest.setupRetrunLevel(numLevelReturn, scoreBack: scoreBack, movesLeftBack: moveleftBack)
            }
            
        }else if let d = segue.destination as? Login{
            print("Go to login page...")
            d.first = true
        }
    }
    
    @IBAction func ratingApp(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to exist out to App Store?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "I'm sure!", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let appID = "1309823348"
            let urlStr = "itms-apps://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
            let urlStr2 = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)" // (Option 2) Open App Review Tab
             UIApplication.shared.openURL(NSURL(string: urlStr)! as URL)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)

    }
   
}
