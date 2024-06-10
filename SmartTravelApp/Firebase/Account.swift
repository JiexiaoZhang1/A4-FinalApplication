

import Foundation
import Firebase
import FirebaseFirestoreSwift

public struct Account : Codable
{
    @DocumentID var documentID:String?
    var username:String
    var password:String
    var gender:String
    var imagepath:String
}
