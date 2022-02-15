//
//  SCNVector3.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/22/22.
//

import Foundation
import UIKit
import SceneKit

extension SCNVector3
{
    // MARK: - SCNVector3 extensions.
    
    /// Pretty-print the value of the instance.
    /// - Parameter WithParentheses: If true, adds parentheses to the result. If false, nothing is added.
    /// - Parameter Nearest: Determines the number of numerals.
    /// - Returns: Pretty-printed value of the instance `SCNVector3`.
    func PrettyPrint(WithParentheses: Bool = true, Nearest: Float = 2) -> String
    {
        var Pretty = "\(Utility.RoundTo(self.x, ToNearest: Nearest)),"
        Pretty = Pretty + "\(Utility.RoundTo(self.y, ToNearest: Nearest)),"
        Pretty = Pretty + "\(Utility.RoundTo(self.z, ToNearest: Nearest))"
        if WithParentheses
        {
            Pretty = "(" + Pretty + ")"
        }
        return Pretty
    }
    
    /// Returns the distance between the instance point and the passed point.
    /// - Parameter Other: The other point used to calculate the distance.
    /// - Returns: The distances between the instance point and the `Other` point.
    func DistanceTo(_ Other: SCNVector3) -> CGFloat
    {
        var XDelta = (self.x - Other.x)
        var YDelta = (self.y - Other.y)
        var ZDelta = (self.z - Other.z)
        XDelta = XDelta * XDelta
        YDelta = YDelta * YDelta
        ZDelta = ZDelta * ZDelta
        let Distance = CGFloat(sqrt(XDelta + YDelta + ZDelta))
        return Distance
    }
    
    /// Returns the value of the instance vector in degrees and rounded to the passed value.
    /// - Parameter Rounding: The number of digits to round the values by. Defaults to `4`.
    /// - Returns: String with the components as degrees of rounded values.
    func DegreeString(Rounding: Int = 4) -> String
    {
        let X = self.x.Degrees.RoundedTo(Rounding)
        let Y = self.y.Degrees.RoundedTo(Rounding)
        let Z = self.z.Degrees.RoundedTo(Rounding)
        let Result = "(\(X)°,\(Y)°,\(Z)°)"
        return Result
    }
}
