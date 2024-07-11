//
//  Constants.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

struct Colors {
    
    static let primaryClr = UIColor(named: "primary")!
    static let primarySubtleClr = UIColor(named: "primary-subtle")!
    static let borderClr = UIColor(named: "borderClr")!
    static let disableBtnBg = UIColor(named: "disbaledBtnBg")!
    static let disableBtnClr = UIColor(named: "disabledBtnClr")!
    static let darkGray = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)

}

enum Storyboard: String {
    case main = "Main"
    
    // MARK: - Therapist
    case therapistOnboarding = "TherapistOnboarding"
    
    // MARK: - Patient Auth
    case patientAuth = "PatientAuth"
    
    // MARK: - MessageTab
    case messageTab = "Message"
    
    // MARK: - Therapist Notifications
    case TherapistNotification = "TherapistNotification"
    
    // MARK: - Patient Exercise Tab
    case patientExercisTab = "PatientExerciseTab"
    
    // MARK: - Exercise Tab
    case exerciseTab = "ExerciseTab"
    
    // MARK: - Therapist Patient Profile
    case therapistPatientProfile = "TherapistPatientProfile"
    
    // MARK: - Therapist Profile
    case therapistProfile = "TherapistProfile"
    
    // MARK: - Therapist Tab
    case therapistTab = "TherapistTab"
    
    // MARK: - Therapist Auth
    case therapistAuth = "TherapistAuth"
    
    // MARK: - Patient Tab
    case patientTab = "PatientTab"
    
    // MARK: - Schedule Tab
    case ScheduleTab = "TherapistCreateSchedule"
    
    // MARK: - Setting Tab
    case setting = "Settings"
}

enum API {
    //MARK: - Local Host

      static let SocketURL = "http://15.156.55.188:8080/"
//    static let baseURL = "http://localhost:8080/"
      static let baseURL = "http://15.156.55.188:8080/"

    
    enum Endpoints {
        //MARK: - Therapist Auth
        static let therapistRegister = "\(baseURL)auth/therapist_register"
        static let therapistLogin = "\(baseURL)auth/therapist_login"
        static let logout = "\(baseURL)logout"
        
        //MARK: - Therapist
        static let updateTherapists = "\(baseURL)update-therapists"
        static let getTherapist = "\(baseURL)get-therapist"
        
        //MARK: - Assign Exercise
        static let addAssignExercise = "\(baseURL)add-assign-exercise"
        static let getAssignExercise = "\(baseURL)get-assign-exercise"
        static let updateAssignExercise = "\(baseURL)update-assign-exercise/"
        
        //MARK: - Exercise
        static let exerciseCategories = "\(baseURL)exercise-categories"
        static let getAllcategories = "\(baseURL)getAllcategories"
        static let addNewExercise = "\(baseURL)add_new_exercise"
        static let getAllExercises = "\(baseURL)get_all_exercises?"
        static let updateExercise = "\(baseURL)updateExercise"
        static let delete_exercise = "\(baseURL)delete_exercise"
        
        //MARK: - Patient
        static let addNewPatients = "\(baseURL)add_new_patients"
        static let getAllPatients = "\(baseURL)get_all_patients"
        static let updatePatients = "\(baseURL)update_patients"
        static let disablePatient = "\(baseURL)disable_patient"
        static let getPatient = "\(baseURL)get_patient"
        
        //MARK: - Notification
        static let getNotificationTime = "\(baseURL)get_notification_time"
        static let newNotificationTime = "\(baseURL)new_Notification_time"
        static let updateNotificationTime = "\(baseURL)update_notification_time"
        static let getTherapistNotification = "\(baseURL)get-therapist-notification"
        
        //MARK: - Patient Auth
        static let patientVerifyEmail = "\(baseURL)patient_email/"
        static let patientLogin = "\(baseURL)patient_login"
        static let patientSetPassword = "\(baseURL)set_password"
        
        //MARK: - Chat
        static let getUserChat = "\(baseURL)/"
        
        //MARK: - Watch Data
        static let watchdata = "\(baseURL)watchdata"
    }
}

extension UserDefaults{
    //MARK: Save User Data
    func setUsernameToken(value: String){
        set(value, forKey: UserDefaultsKeys.usernameToken.rawValue)
    }
    
    func setPatientLoginId(value: String){
        set(value, forKey: UserDefaultsKeys.patientLoginId.rawValue)
    }
    
    func isFirstTimeUser(value: Bool){
        set(value, forKey: UserDefaultsKeys.isFirstTimeUser.rawValue)
    }
    
    func setTherapistId(value: String){
        set(value, forKey: UserDefaultsKeys.therapistId.rawValue)
    }
    
    func setTherapistProfileImage(value: String) {
        set(value, forKey: UserDefaultsKeys.therapistProfileImage.rawValue)
    }
    
    func setTherapistName(value: String) {
        set(value, forKey: UserDefaultsKeys.therapistName.rawValue)
    }
    
    func setPatientName(value: String) {
        set(value, forKey: UserDefaultsKeys.patientName.rawValue)
    }
    
    //MARK: Retrieve User Data
    func getUsernameToken() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.usernameToken.rawValue) as? String ?? ""
    }
    
    func getPatientLoginId() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.patientLoginId.rawValue) as? String ?? ""
    }
    
    func isFirstTimeUser() -> Bool {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstTimeUser.rawValue) as? Bool ?? false
    }
    
    func getTherapistId() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.therapistId.rawValue) as? String ?? ""
    }
    
    func getTherapistProfileImage() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.therapistProfileImage.rawValue) as? String ?? ""
    }
    
    func getTherapistName() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.therapistName.rawValue) as? String ?? ""
    }
    
    func getPatientName() -> String {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.patientName.rawValue) as? String ?? ""
    }
}

enum UserDefaultsKeys : String {
    case usernameToken
    case patientLoginId
    case isFirstTimeUser
    case therapistId
    case therapistProfileImage
    case therapistName
    case patientName
}
