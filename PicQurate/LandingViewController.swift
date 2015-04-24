//
//  ViewController.swift
//  PicQurate
//
//  Created by SongXujie on 17/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    override func viewDidLoad () {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fbLoginButton.delegate = self;
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];
    }
    
    override func viewWillAppear(animated: Bool) {
        if let user = PQ.currentUser {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            });
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("loginSegue", sender: nil);
    }
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("signupSegue", sender: nil);
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler { (connection, user, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
//                var authData = ["id": result.token.userID, "access_token": result.token.tokenString, "expires_at": result.token.expirationDate.description, "platform": "facebook"];
//                NSLog("%@", authData);
//                AVUser.loginWithAuthData(authData, block: { (user, error) -> Void in
//                    if let e = error {
//                        PQ.showError(e);
//                    } else {
//                        NSLog("Facebook log in successful");
//                    }
                //                })
                var email = user["email"] as! String;
                var id = user["id"] as! String;
                var name = user["name"] as! String;
                
                var user = PQUser(email: email, password: id, profileName: name);
                var urlString: String = "https://graph.facebook.com/" + id + "/picture?type=normal";
                var data = NSData(contentsOfURL: NSURL(string: urlString)!);
                var profileImage = UIImage(data: data!);
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    if let e = error {
                        AVUser.logInWithUsernameInBackground(email, password: id, block: { (user, error) -> Void in
                            if let e = error {
                                AVUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
                                    if let e = error {
                                        PQ.showError(e);
                                    } else {
                                        PQ.promote("Password was incorrect. Please check your mailbox to reset pasasword");
                                    }
                                })
                            } else {
                                NSLog("Facebook log in successful");
                            }
                        })
                    } else {
                        user.setProfileImage(profileImage!);
                        PQ.currentUser = user;
                        NSLog("Facebook sign up successful");
                        if let method = PQ.delegate?.onUserRefreshed {
                            method();
                        }
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        AVUser.logOut();
        NSLog("Facebook user logged out");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "signupSegue") {
            
        }
    }

}
