//
//  authService.swift
//  lets_go
//
//  Created by Ishan Singla on 25/04/24.
//

import Foundation

enum AuthServiceError: Error {
    case otpVerificationFailed
    case userNotFound
    case otpExpired
    case otpMismatch
    case emailVerificationFailed
}

class AuthService {
    private var userRepository: UserRepository!
    private var userOtpRepository: UserOtpRepository!
    private var collegeRepository: CollegeRepository!
    private var addressRepository: AddressRepository!
    
    init() {
        userRepository = UserRepository()
        userOtpRepository = UserOtpRepository()
        collegeRepository = CollegeRepository()
        addressRepository = AddressRepository()
    }
    
    func sendOtp(_ email: String) throws -> String {
            let otp = "123456" // Generate a random 6-digit OTP
            // sendOTP(email, otp) // Send the OTP to the user via email
            var userOtp = userOtpRepository.findOne(byEmail: email)
            
            if userOtp != nil{
                userOtp!.otp = otp
                userOtp!.expiry = Date().addingTimeInterval(60 * 5) // OTP expires in 5 minutes
                userOtpRepository.update(userOtp: userOtp!)
                return userOtp!.id
            } else {
                let userOtp = UserOtp(
                    email: email,
                    otp: otp,
                    expiry: Date().addingTimeInterval(60 * 5) // OTP expires in 5 minutes
                )
                userOtpRepository.create(userOtp: userOtp)
                return userOtp.id
            }
    }
    
    func verifyOtp(byId id: String, otp: String) throws -> User {
        let userOtp = userOtpRepository.findOne(byId: id)
        
        if userOtp != nil {
            if userOtp!.expiry < Date() {
                throw AuthServiceError.otpExpired
            }
            if userOtp!.otp == otp {
                let user: User? = userRepository.findOne(byEmail: userOtp!.email)
                if user != nil {
                    UserDefaults.standard.set(user!.id, forKey: "userId")
                    return user!
                }else {
                    throw AuthServiceError.userNotFound
                }
            } else {
                throw AuthServiceError.otpMismatch
            }
        }
        else{
            throw AuthServiceError.otpMismatch
        }
    }
    
    func signupUser(user: User) throws -> Bool {
        userRepository.create(user: user)
        UserDefaults.standard.set(user.id, forKey: "userId")
        return true
    }
    
    func getCurrentUser () throws -> User{
        let id = UserDefaults.standard.object(forKey: "userId")
        if id == nil {
            throw AuthServiceError.userNotFound
        }
        var user = userRepository.findOne(byId: id as! String)
        if user == nil {
            throw AuthServiceError.userNotFound
        }
        user!.college = collegeRepository.findOne(byId: user!.collegeId)
        user!.addresses = addressRepository.findAll(byUserId: user!.id)
        
//        UserDefaults.standard.set(user, forKey: "user")
        return user!
    }
    
    func logout() throws {
        UserDefaults.standard.removeObject(forKey: "userId")
    }
    
    
}
