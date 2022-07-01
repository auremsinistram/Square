//
// CGPoint+Common.swift
//

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import Cocoa
#endif

extension CGPoint {
    
    // MARK: - Internal var
    
    var bounded: CGPoint {
        return CGPoint(
            x: x < 0.0 ? 0.0 : (x > 1.0 ? 1.0 : x),
            y: y < 0.0 ? 0.0 : (y > 1.0 ? 1.0 : y)
        )
    }
}
