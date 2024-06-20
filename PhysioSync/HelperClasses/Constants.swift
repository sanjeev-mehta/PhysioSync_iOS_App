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
    
}

enum API {
    static let baseURL = "http://35.182.100.191/"
    
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
        static let updateAssignExercise = "\(baseURL)update-assign-exercise"
        
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
        
        //MARK: - Notification
        static let getNotificationTime = "\(baseURL)get_notification_time"
        static let newNotificationTime = "\(baseURL)new_Notification_time"
        static let updateNotificationTime = "\(baseURL)update_notification_time"
    }
}
