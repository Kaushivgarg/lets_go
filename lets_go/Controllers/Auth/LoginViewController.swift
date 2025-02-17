//
//  LoginViewController.swift
//  lets_go
//
//  Created by student on 30/04/24.
//

import UIKit

class LoginViewController: UIViewController {
    
//    services
    private var authService: AuthService = AuthService()
    private var userService: UserService = UserService()
    private var userotpId: String!
    
//    outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var confirmEmail: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var otpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        isShowing = false
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
                // Set up tap gesture recognizer to dismiss keyboard
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
       
    }
    @objc func keyboardWillShow(notification: Notification) {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
        
        // Function to handle keyboard disappearing
        @objc func keyboardWillHide(notification: Notification) {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
        
        // Function to dismiss keyboard when tapping outside of text field
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
   

    
    var isShowing = false {
        didSet{
            if isShowing {
                otpLabel.isHidden = false
                otpTextField.isHidden = false
                otpButton.isHidden = false
                confirmEmail.isHidden=true
            } else {
                otpLabel.isHidden = true
                otpTextField.isHidden = true
                otpButton.isHidden = true
                confirmEmail.isHidden = false
            }
        }
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        isShowing = false
//    }
    
    
    @IBAction func confirmEmail(_ sender: Any) {
        
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your college Email.")
            return
        }
        do {
            try userService.verifyEmailWithCollegeDomain(email: email)
            isShowing = true
            userotpId = try authService.sendOtp(email)
            showAlert(message: "OTP sent to your email.")
        } catch {
            isShowing = false
            showAlert(message: "Please enter a valid college Email.")
            return
        }
        return
    }
    
    
    @IBAction func confirmOtp(_ sender: Any) {
        guard let otp = otpTextField.text, !otp.isEmpty else {
            showAlert(message: "Please enter Otp OTP.")
            return
        }
        do {
            let user = try authService.verifyOtp(byId: userotpId, otp: otp)
            let storyboard = UIStoryboard(name: "AuthorisedApp", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
//            performSegue(withIdentifier: "completeInfoIdentifier", sender: user)
        } catch {
            if let error = error as? AuthServiceError {
                switch error {
                case .userNotFound:
                    performSegue(withIdentifier: "SignupVC", sender: nil)
                    return
                case .otpMismatch:
                    showAlert(message: "Invalid OTP.")
                    return
                case .otpExpired:
                    showAlert(message: "OTP has expired.")
                    return
                default:
                    showAlert(message: "OTP verification failed.")
                    return
                }
            }
            showAlert(message: "Invalid OTP.")
            return
        }
        
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Signup", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
 

}
