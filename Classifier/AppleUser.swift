//
//  AppleUser.swift
//  Ne Ararsan Var
//
//  Created by bora on 9.02.2021.
//  Copyright © 2021 Developer Bora Ateş. All rights reserved.
//

import Foundation
import AuthenticationServices

struct AppleUser {
    let id: String
    let firstname: String
    let lastname: String
    let email: String
    
    init(credentials: ASAuthorizationAppleIDCredential) {
        self.id = credentials.user
        self.firstname = credentials.fullName?.givenName ?? ""
        self.lastname = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
    }
}

extension AppleUser: CustomDebugStringConvertible{
    var debugDescription: String{
        return """
            ID: \(id)
            First Name: \(firstname)
            Last Name: \(lastname)
            Email: \(email)
            """
    }
}
