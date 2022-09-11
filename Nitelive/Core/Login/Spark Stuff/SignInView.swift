//
//  SignInView.swift
//  SwiftUISignInWithAppleAndFirebaseDemo
//
//  Created by Alex Nagy on 08/12/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        ActivityIndicatorView(isPresented: $activityIndicatorInfo.isPresented, message: activityIndicatorInfo.message) {
            Spacer()
        }
    }
    
    // MARK: - Activity Indicator
    @State private var activityIndicatorInfo = SparkUIDefault.activityIndicatorInfo

    func startActivityIndicator(message: String) {
        activityIndicatorInfo.message = message
        activityIndicatorInfo.isPresented = true
    }

    func stopActivityIndicator() {
        activityIndicatorInfo.isPresented = false
    }

    func updateActivityIndicator(message: String) {
        stopActivityIndicator()
        startActivityIndicator(message: message)
    }
    
    // MARK: - Alert
    @State private var alertInfo = SparkUIDefault.alertInfo
    
    func presentAlert(title: String, message: String, actionText: String = "Ok", actionTag: Int = 0) {
        alertInfo.title = title
        alertInfo.message = message
        alertInfo.actionText = actionText
        alertInfo.actionTag = actionTag
        alertInfo.isPresented = true
    }
    
    func executeAlertAction() {
        switch alertInfo.actionTag {
        case 0:
            print("No action alert action")
            
        default:
            print("Default alert action")
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
