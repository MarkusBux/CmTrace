//
//  AppPreferences.swift
//  CmTrace2
//
//  Created by Markus Bux on 17.12.20.
//

import Foundation
import os

/// Application preferences
class AppPreferences {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier! , category: "\(AppPreferences.self)")
    
    private let userDefaults = UserDefaults.standard
    
    enum AppPreferenceValues:String {
        case highlightWarningMessages
        case highlightErrorMessages
        case presentOpenFileDialogOnLoad
    }
    
    /// Shared default instance of the preferences
    private (set) static var shared = AppPreferences()
    
    private init() {
        highlightErrorMessages = userDefaults.bool(forKey: AppPreferenceValues.highlightErrorMessages.rawValue)
        highlightWarningMessages = userDefaults.bool(forKey: AppPreferenceValues.highlightWarningMessages.rawValue)
        presentOpenFileDialogOnLoad = userDefaults.bool(forKey: AppPreferenceValues.presentOpenFileDialogOnLoad.rawValue)
    }
    
    var presentOpenFileDialogOnLoad: Bool {
        willSet {
            logger.debug("Saving 'presentOpenFileDialogOnLoad' with new value of '\(newValue.description)'")
            userDefaults.setValue(newValue, forKey: AppPreferenceValues.presentOpenFileDialogOnLoad.rawValue)
        }
    }
    
    var highlightWarningMessages: Bool {
        willSet {
            logger.debug("Saving 'highlightWarningMessages' with new value of '\(newValue.description)'")
            userDefaults.setValue(newValue, forKey: AppPreferenceValues.highlightWarningMessages.rawValue)
        }
    }
    
    var highlightErrorMessages: Bool {
        willSet {
            logger.debug("Saving 'highlightErrorMessages' with new value of '\(newValue.description)'")
            userDefaults.setValue(newValue, forKey: AppPreferenceValues.highlightErrorMessages.rawValue)
        }
    }
}
