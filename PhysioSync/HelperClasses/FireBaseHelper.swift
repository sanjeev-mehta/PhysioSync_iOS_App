//
//  FireBaseHelper.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 20/06/24.
//

import FirebaseAuth

class FirebaseHelper {
    
    static let shared = FirebaseHelper()
        
    // MARK: - Sign In
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Send Verification Email
    
    func sendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            completion(.failure(NSError(domain: "FirebaseHelper", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user."])))
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.sendVerificationEmail { result in
                        switch result {
                        case .success:
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Check Current User
    
    func checkCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.reload { error in
                if let error = error {
                    completion(.failure(error))
                } else if user.isEmailVerified {
                    completion(.success(()))
                } else {
                    let notVerifiedError = NSError(domain: "FirebaseHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Email is not verified."])
                    completion(.failure(notVerifiedError))
                }
            }
        } else {
            completion(.failure(NSError(domain: "FirebaseHelper", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user."])))
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
    func checkEmailAuthentication(_ email: String, _ password: String, completion: @escaping (Bool, Int?) -> ()) {
        FirebaseHelper.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
//                print("User signed in: \(user.email ?? "No email")")
                FirebaseHelper.shared.checkCurrentUser { result in
                    switch result {
                    case .success:
                        print("User email is verified.")
                        completion(true, 0)
                    case .failure(let error):
                        if let nsError = error as NSError?, nsError.code == 1 {
                            print("User email is not verified.")
                            FirebaseHelper.shared.sendVerificationEmail { result in
                                switch result {
                                case .success:
                                    print("Verification email sent.")
                                    completion(false, 1)
                                case .failure(let error):
                                    print("Error sending verification email: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            print("Error checking current user: \(error.localizedDescription)")
                            completion(false, 2)
                        }
                    }
                }
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
                completion(false, 2)
            }
        }
    }
}
