//
//  Account.swift
//  SmartTravelApp
//
//  Created by student on 28/5/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

public struct Account : Codable
{
    @DocumentID var documentID:String?
    var username:String
    var password:String
}
