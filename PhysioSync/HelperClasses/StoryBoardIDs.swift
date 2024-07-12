//
//  StoryBoardIDs.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import Foundation

enum StoryBoardIDs: String {
    // MARK: - Welcome StoryBoard
    case welcomeID = "WelcomeVC"
    
    // MARK: - Therapist Onboarding Storyboard
    case therapistOnboardingID = "TherapistOnboardingVC"
    case therapistWelcomeID = "TherapistWelcomeVC"
    
    // MARK: - Patient Auth Storyboard
    case patientLogin = "PatientLoginVC"
    case setPassword = "SetPasswordVC"
    
    // MARK: - Message Tab StoryBoard
    case MessageTabVC = "MessageTabVC"
    case chatVC = "ChatScreenVC"
    
    // MARK: - Therapist Notification Tab
    
    case TherapistNotificationVC = "TherapistNotificationVC"
    
    // MARK: - Patient Exercise Tab Storyboard
    case patientExerciseTab = "PatientExerciseTabVC"
    case patientExerciseDetail = "PatientExerciseDetailVC"
    
    // MARK: - Exercise Tab
    case exerciseCategoryVC = "ExerciseCategoryVC"
    case singleExerciseVC = "SingleExerciseVC"
    case singleExerciseDetailVC = "SingleExerciseDetailVC"
    case addNewExerciseVC = "AddNewExerciseVC"
    
    //MARK: - Therapist Patient Profile
    case therapistPatientProfileVC = "TherapistPatientProfileVC"
    case therapistPatientInfoVC = "TherapistPatientInfoVC"
    case therapistPatientStep1VC = "TherapistPatientStep1VC"
    case therapistPatientStep2VC = "TherapistPatientStep2VC"
    case therapistPatientStep3VC = "TherapistPatientStep3VC"
    
    // MARK: -  Therapist Profile
    case therapistProfileStep1VC = "TherapistProfileStep1VC"
    case therapistProfileStep2VC = "TherapistProfileStep2VC"
    
    // MARK: -  Therapist Tab
    case therapistProfileVC = "TherapistProfileVC"
    case tabBarController = "tabBarController"
    
    //MARK: - Therapist Auth
    case therapistLoginVC = "TherapistLoginVC"
    
    //MARK: -  Patient Tab
    case patientTabBarController = "patientTabBarController"
    
    //MARK: -  Schedule Tab
    case createScheduleVC = "CreateScheduleVC"
    
    //MARK: - Settings
    case settingVC = "SettingsVC"
}
