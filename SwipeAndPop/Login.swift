//
//  Login.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 14.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn


class Login: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var bubbleImage: UIImageView!
    @IBOutlet weak var monkeyLoginImage: UIImageView!
    
    var blurView:UIVisualEffect!
    @IBOutlet weak var blurEffect: UIVisualEffectView!{
        didSet{
            blurView = blurEffect.effect
            blurEffect.effect = nil
        }
    }
    
    @IBOutlet var registerView: UIView!
    var isDialogVisible:Bool = false
    
    @IBOutlet weak var emailTextField: UITextField!
    
   // @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func registerBtn(_ sender: UIButton) {
        if emailTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your name", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
          
//            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
//                if error == nil {
//                    print("You have successfully signed up")
//                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
//
//                    self.performSegue(withIdentifier: "masterToGame", sender: user)
//
//
//                } else {
            
//                    Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, err) in
//                        if err == nil {
//                            print("You have successfully signed up")
//                            //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
//
//                            self.performSegue(withIdentifier: "masterToGame", sender: user)
//                        }else{
//
//                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
//
//                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                            alertController.addAction(defaultAction)
//
//                            self.present(alertController, animated: true, completion: nil)
//                        }
//                    })
//                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
//
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//
//                    self.present(alertController, animated: true, completion: nil)
//                }
            //}
        }
    }
    
    func addNewData() {
        
        let database = Database.database()
        let auth = Auth.auth()
        
        guard let user = auth.currentUser else{
            print("no user")
            return
        }
        
        var name = user.displayName ?? user.email
        var email = user.email ?? "anonymous"
        
        if user.isAnonymous{
            name = "Guest"
            email = "anonymous"
        }
        let tabRef = database.reference(withPath: "UserDataGame").child(user.uid)
        
        let t = DataGame(name: name!, ownerID: user.uid, ownerName: email)
        
        
        tabRef.setValue(t.json)
        
        
        
    }
    
    var r = 9
    func animRotate()  {
        
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.rotation"
        animation.values = [ -45 * Float.pi / 180, 45 * Float.pi / 180]
        animation.keyTimes = [0, 0.5]
        animation.autoreverses = true
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.isAdditive = true
        
        monkeyLoginImage.layer.add(animation, forKey: "move")
        
        //        monkeyLoginImage.startAnimating()
        //        repeat{
        //        UIView.animateKeyframes(withDuration: 7, delay: 0, options: .autoreverse, animations: {
        //
        //                self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: -45)
        //
        //
        //
        //
        //        }) { (c) in
        //            print("ff")
        //        }
        //        }while r == 0
        //        UIView.animate(withDuration: 3) {
        //
        //            self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: 45)
        //
        //        }
    }
    
    
    let fullRotation = CGFloat(M_PI / 180.0)
    func rotateDegree(duration: CFTimeInterval = 7.0) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .repeat, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                // start at 0.00s (5s × 0)
                // duration 1.67s (5s × 1/3)
                // end at   1.67s (0.00s + 1.67s)
                self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: -45 * self.fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 1/3, animations: {
                self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: 0 * self.fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1/3, animations: {
                self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: 15 * self.fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1/3, animations: {
                self.monkeyLoginImage.transform = CGAffineTransform(rotationAngle: 0 * self.fullRotation)
            })
        }, completion: {finished in
            // any code entered here will be applied
            // once the animation has completed
            
        })
    }
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    var first:Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rotateDegree()
        Auth.auth().removeStateDidChangeListener(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let temp = monkeyLoginImage.layer.position
        
        monkeyLoginImage.layer.anchorPoint = CGPoint(x: 0.75, y: 0)
        monkeyLoginImage.layer.position = CGPoint(x: 140, y: 0.5)
        
        
        //   animRotate()
        print("+++++++++\(first)")
        
        
        Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            
            
            if user != nil  && ( self?.first ?? false){
                
                
                self?.first = false
                self?.addNewData()
                print("+++++()()(()(()++++++++\(user!.displayName, user?.email)")
                self?.performSegue(withIdentifier: "masterToGame", sender: user)
                

            }else{
                do{
                    try Auth.auth().signOut()
                    FBSDKLoginManager().logOut()
                    self?.first = true
                    print("listener not listen >>>")
                }
                catch let error{
                    print(error)
                }
                
                
            }
            
        }
        
        //        let accessToke = FBSDKAccessToken.current()
        //        guard let accessTokenString = accessToke?.tokenString else {return}
        //
        //
        //        let credentials = Firebase.FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        //
        //        Auth.auth().signIn(with: credentials, completion: { (user, error) in
        //            if let error = error{
        //                print(error)
        //                return
        //            }
        //            if let user = user{
        //                self.performSegue(withIdentifier: "masterToGame", sender: user)
        //            }
        //        })
        
        bubbleImage.alpha = 0.0
        fadeIn()
        //fadeOut()
        
        
        
        emailTextField.delegate = self
        //passwordTextField.delegate = self
        
        setupFacebookButtons()
        
        setupGoogleButtons()
        
        customLoginButton()
        
    }
    
    
    func fadeIn(withDuration duration: TimeInterval = 5.0) {
        
        UIView.animate(withDuration: duration, animations: {
            
            self.bubbleImage.alpha = 1.0
            self.bubbleImage.transform.rotated(by: 360)
            
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.bubbleImage.alpha = 0.0
        })
    }
    func dismissDialog()  {
        UIView.animate(withDuration: 0.6, animations: {
            self.registerView.transform = CGAffineTransform(translationX: 0, y: -1000)
        }) { (complete) in
            self.blurEffect.effect = nil
            self.registerView.removeFromSuperview()
        }
        isDialogVisible = false
    }
    
    func showDialog() {
        
        registerView.center.x = self.view.center.x
        registerView.center.y = self.view.center.y
        registerView.layer.borderWidth = 2
        registerView.layer.cornerRadius = 10
        registerView.layer.borderColor = UIColor.black.cgColor
        //transforms: CGAffineTransform
        //scale
        //rottate
        //tranision (x,y)
        //identity
        
        registerView.transform = CGAffineTransform(translationX: 0, y: -1000)
        view.addSubview(registerView)
        
        UIView.animate(withDuration: 0.6) {
            self.registerView.transform = CGAffineTransform.identity
            self.blurEffect.effect = self.blurView
        }
        
        isDialogVisible = true
    }
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil{
                print("Custom Btn login failed:" , err)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func setupGoogleButtons() {
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 48, y: (view.frame.height / 2) +  66, width: view.frame.width -  96, height: 50)
        
        view.addSubview(googleButton)
        
        //        let customButton = UIButton(type: .system)
        //        customButton.frame = CGRect(x: 48, y: (view.frame.height / 2) +  198, width: view.frame.width -  96, height: 50)
        //        customButton.backgroundColor = UIColor.orange
        //        customButton.setTitle("Custom login Google", for: .normal)
        //        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //        customButton.setTitleColor(UIColor.white, for: .normal)
        //        view.addSubview(customButton)
        //
        //        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func customLoginButton() {
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 48, y: (view.frame.height / 2) +  132, width: view.frame.width -  100, height: 40)
        customButton.backgroundColor = UIColor.brown
        customButton.setTitle("Log in Anonymously", for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.layer.cornerRadius = 3
        view.addSubview(customButton)
        
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
    }
    
    @objc func handleCustomGoogleSign() {
        //        GIDSignIn.sharedInstance().signIn()
//        if !isDialogVisible {
//            showDialog()
//        }
        
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error{
                print(error)
                return
            }
            if let user = user{
                
                self.emailTextField.isEnabled = false
                //self.performSegue(withIdentifier: "masterToGame", sender: user)
            }
        }
    }
    
    
    func setupFacebookButtons()  {
        let loginButton = FBSDKLoginButton()
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 48, y: (view.frame.height / 2) + 8, width: view.frame.width -  100, height: 40)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        //custom button login
        //        let customFBButton = UIButton(type: .system)
        //        customFBButton.backgroundColor = UIColor.blue
        //        customFBButton.frame = CGRect(x: 48, y: (view.frame.height / 2) +  66, width: view.frame.width -  96, height: 50)
        //        customFBButton.setTitle("Custom login BTN", for: .normal)
        //        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //        customFBButton.setTitleColor(UIColor.white, for: .normal)
        //        view.addSubview(customFBButton)
        
        //        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("did log out face...")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        let accessToke = FBSDKAccessToken.current()
        guard let accessTokenString = accessToke?.tokenString else {return}
        
        let credentials = Firebase.FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let error = error{
                print(error)
                return
            }
            if let user = user{
               // self.performSegue(withIdentifier: "masterToGame", sender: user.ui)
            }
        })
        
        print("succes login")
        
        showEmailAddress()
        
    }
    
    func showEmailAddress() {
        let accessToke = FBSDKAccessToken.current()
        guard let accessTokenString = accessToke?.tokenString else {return}
        
        let credentials = Firebase.FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, err) in
            if err != nil{
                print("somthing went wrong", err)
                return
            }
            print("Successfully logged in with our FB user: ", user ?? "")
            
        }
        
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("failed graph request", err)
                return
            }
            
            print(result)
        }
    }
    
    func resignKeyboard(view: UIView){
        view.subviews.forEach { (v) in
            if v is UITextField {
                v.resignFirstResponder()
            }else{
                resignKeyboard(view: v)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignKeyboard(view: self.view)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignKeyboard(view: self.view)
        var inRange:Bool = true
        
        guard let p = touches.first?.location(in: view) else {return}
        if !registerView.frame.contains(p) {
            dismissDialog()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? GameViewController{
            let user = Auth.auth().currentUser
            let userInfo = user?.providerData.first
            if userInfo?.providerID == "facebook.com" {
                
                if dest.movesLeft == 0{
                    dest.movesLeft += 10
                    dest.levelNum = 1
                }
            }
            dest.levelNum = 1
            
        }
    }
}


