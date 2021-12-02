//
//  AppUtils.swift
//  Vibrations
//
//  Created by Siddhesh on 02/12/21.
//

import UIKit

class AppUtils{
    
    static func normalizeCoordinates(_ point: CGPoint, toView paletteView: UIView) -> CGPoint {
        
        let width = paletteView.bounds.width
        let height = paletteView.bounds.height
        
        return CGPoint(x: point.x / width,
                       y: point.y / height)
    }
    
    static func getDynamicValue(touch: UITouch, view: UIView) -> Float{
        let location = touch.location(in: view)
        let normalizedLocation = normalizeCoordinates(location, toView: view)
        let dynamicValue: Float = 1 - Float(normalizedLocation.y)
        let initialValue:Float = 1.0
        let perceivedValue = initialValue * dynamicValue
       // print("perceivedValue",perceivedValue)
        return perceivedValue
    }
}
