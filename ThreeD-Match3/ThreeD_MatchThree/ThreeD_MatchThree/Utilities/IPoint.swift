//
//  IPoint.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/11/22.
//

import Foundation
import UIKit

/// Very simple point class for integers.
class IPoint: Equatable, CustomDebugStringConvertible
{
    /// Initializer.
    /// - Parameter X: Initial X value.
    /// - Parameter Y: Initial Y value.
    /// - Parameter Other: If provided, initial ancillary point value.
    init(_ X: Int, _ Y: Int, Other: IPoint? = nil)
    {
        self.X = X
        self.Y = Y
        Ancillary = Other
    }
    
    /// Initializer.
    /// - Parameter X: Initial X value.
    /// - Parameter Y: Initial Y value.
    /// - Parameter Other: If provided, initial ancillary point value.
    init(X: Int, Y: Int, Other: IPoint? = nil)
    {
        self.X = X
        self.Y = Y
        Ancillary = Other
    }
    
    /// Initializer.
    /// - Parameter Both: Initial value to assign to both `X` and `Y`.
    /// - Parameter Other: If provided, initial ancillary point value.
    init(_ Both: Int, Other: IPoint? = nil)
    {
        self.X = Both
        self.Y = Both
        Ancillary = Other
    }
    
    /// Initializer.
    /// - Parameter CG: Source point in `CGPoint` format. all values are truncated to `Int`s.
    /// - Parameter Other: If provided, initial ancillary point value.
    init(_ CG: CGPoint, Other: IPoint? = nil)
    {
        self.X = Int(CG.x)
        self.Y = Int(CG.y)
        Ancillary = Other
    }
    
    /// Determines if the current `X` and `Y` values are in passed range.
    /// - Parameter Low: Low value. `X` and `Y` must both be this value or greater.
    /// - Parameter High: High value. `X` and `Y` must both be this value or less.
    /// - Returns: True if `X` and `Y` fall into the passed range, false if not.
    public func IsInRange(_ Low: Int, _ High: Int) -> Bool
    {
        if X < Low && Y < Low
        {
            return false
        }
        if X > High || Y > High
        {
            return false
        }
        return true
    }
    
    /// X value. Defaults to `0`.
    var X: Int = 0
    
    /// Y Value. Defaults to `0`.
    var Y: Int = 0
    
    /// Ancillary point. Defaults to `nil`.
    var Ancillary: IPoint? = nil
    
    /// Return the contents of the instance as a `CGPoint`.
    /// - Returns: CGPoint equivalent of the contents of this instance.
    func AsCGPoint() -> CGPoint
    {
        return CGPoint(x: X, y: Y)
    }
    
    // MARK: - Equatable implementation.
    
    static func == (lhs: IPoint, rhs: IPoint) -> Bool
    {
        return lhs.X == rhs.X && lhs.Y == rhs.Y
    }
    
    static func != (lhs: IPoint, rhs: IPoint) -> Bool
    {
        return !(lhs == rhs)
    }
    
    // MARK: - CustomDebugStringConvertible implementation.
    
    var debugDescription: String
    {
        return "(\(X),\(Y))"
    }
}
