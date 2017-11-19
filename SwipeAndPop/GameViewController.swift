//
//  GameViewController.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 2.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import FBSDKLoginKit

class GameViewController: UIViewController {
    
    var messageTimer: Timer!
    @IBOutlet var startView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var playBtnVar: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var readySwipeLabel: UILabel!
    
    @IBOutlet var finishView: UIView!
    
    @IBOutlet weak var finishUserLabel: UILabel!
    
    @IBAction func newGameViewBtn(_ sender: UIButton) {
        dismissDialog(viewDialog: finishView)
        if levelNum > 6 {
             levelNum = 1
            setupLevel(levelNum)
           
            
        }
    }
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBAction func playBtn(_ sender: UIButton) {
        dismissDialog(viewDialog: startView)
        if levelNum > 6 {
            setupLevel(1)
            levelNum = 1
        }
        //setupLevel(levelNum)
    }
    @IBOutlet weak var shuffleImage: UIImageView!
    
    @IBAction func shuffleButton(_ sender: UIButton) {
     
        shuffle()
        decrementMoves()
        updateLabels()
    }
    
    @IBAction func settingBtn(_ sender: UIButton) {
        
        do{
           self.performSegue(withIdentifier: "gameToLogin", sender: self)
        }
        catch let error{
            print(error)
        }
        
    }
    
    var user:User!
    var userName:String!{
        didSet{
            print(userName)
        }
    }
    
    var dataUser = [DataGame]()

    
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var gameOverImage: UIImageView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var scorLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    
    @IBOutlet weak var moveStack: UIStackView!
    
    var scene: GameScene!
    
    var level: Level!
    
    var levelNum = 1
    
    var isDialogVisible = false
    
//    func showDialog() {
//
//        startView.center.x = self.view.center.x
//        startView.center.y = self.view.center.y
//        startView.layer.borderWidth = 2
//        startView.layer.cornerRadius = 15
//        startView.layer.borderColor = UIColor.white.cgColor
//        //transforms: CGAffineTransform
//        //scale
//        //rottate
//        //tranision (x,y)
//        //identity
//        startView.transform = CGAffineTransform(translationX: 0, y: -1000)
//        view.addSubview(startView)
//
//        UIView.animate(withDuration: 0.6) {
//            self.startView.transform = CGAffineTransform.identity
//        }
//
//        isDialogVisible = true
//    }
    
    func showDialog(viewDialog: UIView) {
        
        viewDialog.center.x = self.view.center.x
        viewDialog.center.y = self.view.center.y
        viewDialog.layer.borderWidth = 2
        viewDialog.layer.cornerRadius = 15
        viewDialog.layer.borderColor = UIColor.white.cgColor
        
        viewDialog.transform = CGAffineTransform(translationX: 0, y: -1000)
        view.addSubview(viewDialog)
        
        UIView.animate(withDuration: 0.6) {
            viewDialog.transform = CGAffineTransform.identity
        }
        
        isDialogVisible = true
    }
    func dismissDialog(viewDialog: UIView)  {
        UIView.animate(withDuration: 0.6, animations: {
            viewDialog.transform = CGAffineTransform(translationX: 0, y: -1000)
        }) { (complete) in
            viewDialog.removeFromSuperview()
        }
        isDialogVisible = false
    }
    
    func setupLevel(_ levelNum: Int) {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        //skView.showsNodeCount = true
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Setup the level.
        level = Level(filename: "Level_\(levelNum)")
        scene.level = level
        
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        
        gameOverImage.isHidden = true
        //shuffleButton.isHidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Start the game.
        beginGame()
       // handleMatchesAtTheBegin()
//        movesLeft += level.maximumMoves
//        score = 0
//        updateLabels()
//        scene.animateBeginGame {
//
//        }
//        shuffle()
    }
    
    
    func setupRetrunLevel(_ levelNum: Int, scoreBack: Int, movesLeftBack: Int ) {
        dismissDialog(viewDialog: startView)
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Setup the level.
        level = Level(filename: "Level_\(levelNum)")
        scene.level = level
        
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        gameOverImage.isHidden = true
        //shuffleButton.isHidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        movesLeft = movesLeftBack + 1
        score = scoreBack
        updateLabels()
        scene.animateBeginGame {
            self.fadeIn()
        }
        shuffle()
        handleMatches()
   
    }
    
    func beginGame() {
        
        movesLeft += level.maximumMoves
        score = 0
        updateLabels()
        scene.animateBeginGame {
            self.fadeIn()
        }
        shuffle()
        handleMatches()
        
    }
    var oldSet:Set<Character>!
    
    func shuffle() {
        scene.removeAllCharactereSprites()
        
        let newCharacters = level.shuffle()
        oldSet = newCharacters
        scene.addSprites(for: newCharacters)
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        moveLabel.text = String(format: "%ld", movesLeft)
        scorLabel.text = String(format: "%ld", score)
    }
    var gradientLayer: CAGradientLayer!
    
    func createGradientLayer(viewD: UIView) {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = viewD.bounds
        
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.yellow.cgColor]
        
        gradientLayer.cornerRadius = 15
        gradientLayer.borderWidth = 2
        
        viewD.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    var totalUserLevel = 0
    
    @IBOutlet weak var btnShuffle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewData()
        createGradientLayer(viewD: startView)
        createGradientLayer(viewD: finishView)
        
        
        playBtnVar.layer.cornerRadius = 5
        playBtnVar.layer.borderColor = UIColor.gray.cgColor
        playBtnVar.layer.borderWidth = 2
        showDialog(viewDialog: startView)
        
        user = Auth.auth().currentUser
   
        
                        Database.database().reference(withPath: "UserLevelAndScore").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            let json = snapshot.value as! [String: Any]
                            print("😎Here THE USER DATA: \(json)")
                            print("😎child count: \(snapshot.childrenCount)")
        
                            self.totalUserLevel = Int(snapshot.childrenCount)
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
        
        
        
        if user != nil{
            var emailName = user.email
            var name = user.displayName
            emailName?.removeLast(10)
            if user.isAnonymous{
                name = "Guest"
                emailName = "anonymous"
            }
           userLabel.text = name ?? emailName ?? ""
           finishUserLabel.text = name ?? emailName ?? ""
            levelLabel.text = "<< Lavel \(levelNum) >>"
        }
       
      
        shuffleImage.alpha = 0.0
        
        //        print("@@@@@@\(Auth.auth().currentUser?.)")
        /*
         Since a user can sign into their Firebase Authentication account with multiple providers, the top-level provider ID will now (usually) we Firebase.
         
         But the currentUser has a providerData property that provides information on the speciic providers. Looping over FIRAuth.auth()!.currentUser.providerData will give you the FIRUserInfo.providerID you're looking for.
         */
        
        guard let userInfo:[UserInfo] = Auth.auth().currentUser?.providerData else {return}
        
        
        
        for info in userInfo {
            print("!!!")
            print(info.providerID)
        }
        
        setupLevel(levelNum)
        
//        let userRef = Database.database().reference(withPath: "UserDataGame")
//
//        userRef.observe(.childAdded, with: { (snapShot) in
//            let json = snapShot.value as! [String: Any]
//            let dataGame = DataGame(json: json)
//            self.dataUser.append(dataGame)
//
//
//        })
//        let setCount = level.checkForHintVerticalMatches().isEmpty
//        let v = setCount.description
//        let note = Notification.Name(v)
//
//        NotificationCenter.default.post(name: note, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(doShuffle), name: note, object: nil)
    
        

        
        
    }
    
//    @objc func doShuffle() {
//        if level.checkForHintVerticalMatches().isEmpty{
//        print("🐒 emptySet... ---->>>>>>")
//        shuffle()
//        }
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if level.checkForHintVerticalMatches().isEmpty{
//            print("🐒 emptySet...")
//            shuffle()
//        }
    }
    func addNewData() {

        let database = Database.database()
        let auth = Auth.auth()

        guard let user = auth.currentUser else{
            print("no user")
            return
        }

        let tabRef = database.reference(withPath: "UserLevelAndScore").child(user.uid).child("Level \(levelNum)")

  
        var score = scorLabel.text ?? "no score yet"
    


        let t = UserScoreData(ownerID: user.uid, ownerLevel: "\(levelNum)", ownerScore: score, ownerTotalScore: "\(totalScore)")


        tabRef.setValue(t.json)

    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    var isSwaped:Bool = false
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animate(swap: swap, completion: handleMatches)
            isSwaped = true
        } else {
            self.isSwaped = false
            scene.animateInvalidSwap(swap, completion: {
                self.view.isUserInteractionEnabled = true
                
            })
        }
    }
    
    func handleMatchesAtTheBegin() {
        // Detect if there are any matches left.

        let chains = level.removeMatches()
        
        // If there are no more matches, then the player gets to move again.
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        // First, remove any matches...
        scene.animateMatchedCharacters(for: chains) {
            
            // Add the new scores to the total.
//            for chain in chains {
//                self.score += chain.score
//            }
//            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCharacterFor(columns: columns, completion: {
                let columns = self.level.topUpCharacters()
                self.scene.animateNewCharacter(columns) {
                    
                    // Keep repeating this cycle until there are no more matches.
                    self.handleMatches()
                }
            })
        }
    }
    
    func handleMatches() {
        // Detect if there are any matches left.
        let chains = level.removeMatches()
        
        // If there are no more matches, then the player gets to move again.
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        // First, remove any matches...
        scene.animateMatchedCharacters(for: chains) {
            
            // Add the new scores to the total.
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCharacterFor(columns: columns, completion: {
                let columns = self.level.topUpCharacters()
                self.scene.animateNewCharacter(columns) {
                    
                    self.handleMatches()
                }
            })
        }
    }

   
    @objc func fadeIn(withDuration duration: TimeInterval = 8.0) {
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.shuffleImage.alpha = 1.0
            self.shuffleImage.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            
        }) { (complete) in
            UIView.animate(withDuration: duration, animations: {
                self.shuffleImage.alpha = 0.0
                self.shuffleImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            self.shuffleImage.alpha = 0.0
           
        }
        
    }
    
    func beginNextTurn() {
        //level.checkForHintVHlMatches()
        if /*level.checkForHintHorizontalMatches().isEmpty && level.checkForHintVerticalMatches().isEmpty &&*/ level.checkForHintVHlMatches().isEmpty{
            print("🐒 emptySet...")
            //shuffle()
            
        }
        
      
        
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
        decrementMoves()
       
        
        let userRef = Database.database().reference(withPath: "UserDataGame")
        
                userRef.observe(.childAdded, with: { (snapShot) in
                    let json = snapShot.value as! [String: Any]
                    let dataGame = DataGame(json: json)
                    self.dataUser.append(dataGame)
        
                })
        //print("%%%%$$***** \(dataUser.description)")
    }
    
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        if score >= level.targetScore {
             addNewData()
            gameOverImage.image = UIImage(named: "greatwork")
            showGameOver()
            levelNum += 1
        } else if movesLeft <= 0 {
             addNewData()
            gameOverImage.image = UIImage(named: "gameOver")
            showGameOver()
            levelNum = 1
            
        }
        
       
    }
    
    func showGameOver() {
        btnShuffle.isUserInteractionEnabled = true
        gameOverImage.isHidden = false
        scene.isUserInteractionEnabled = false
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func gameFinish(){
        if levelNum > 6{
//            readySwipeLabel.text = "👑 You've Finished The Game 👑"
//            playBtnVar.titleLabel?.text = "New Play >>>"
//            helloLabel.text = "Congratulations,"
//            levelLabel.text = "<< 👏👏👏 >>"
            showDialog(viewDialog: finishView)
        }
    }
    var totalScore = 0
    
    @objc func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverImage.isHidden = true
        scene.isUserInteractionEnabled = true
        
        totalScore += score
        
        movesLeft = 0
        if levelNum > 6 {
            gameFinish()
            return
        }
        setupLevel(levelNum)
        btnShuffle.isUserInteractionEnabled = false
    }
    
    
    var changeMoveLeft = 0
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isSwaped{
            changeMoveLeft += 1
        
        if changeMoveLeft == 4{
            print("touchEnd")

            fadeIn()
     
            changeMoveLeft = 0
        }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SettingViewController{
            
            dest.levelCount = totalUserLevel
            print("👑\(totalUserLevel)")
            
            dest.scoreLabel = scorLabel
            dest.numLevelReturn = levelNum
            dest.moveleftBack = movesLeft
            dest.scoreBack = score
            dest.scene = scene
            dest.oldSet = oldSet
//            let user = Auth.auth().currentUser
//            let userInfo = user?.providerData.first
          
//                dest.nameLabel.text = user?.displayName ?? user?.email
//                dest.scoreLabel.text = "Score: \(String(score))"
            }
       
        }
    }


