//
//  Card.swift
//  UI-696
//
//  Created by nyannyan0328 on 2022/10/12.
//

import SwiftUI

struct Card: Identifiable {
    var id = UUID().uuidString
    var imageName : String
    var isRotated : Bool = false
    var extractOffset : CGFloat = 0
    var scale : CGFloat = 1
    var zindex : Double = 0
    
    
}

