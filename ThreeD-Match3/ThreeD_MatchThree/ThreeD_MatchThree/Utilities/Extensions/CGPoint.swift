//
//  CGPoint.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 2/7/22.
//

import Foundation
import UIKit

extension CGPoint
{
    /// Returns the mid-point between the two passed points.
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Returns: Point that is midway between `Point1` and `Point2`.
    public static func MidPoint(_ Point1: CGPoint, _ Point2: CGPoint) -> (Point: CGPoint, XDelta: CGFloat, YDelta: CGFloat)
    {
        //print("Point1=\(Point1), Point2=\(Point2)")
        let DeltaX = abs(Point1.x - Point2.x)
        let DeltaY = abs(Point1.y - Point2.y)
        let Left = min(Point1.x, Point2.x)
        let Top = min(Point1.y, Point2.y)
        //print("Left=\(Left), Top=\(Top)")
        let HalfDeltaX = DeltaX / 2.0
        let HalfDeltaY = DeltaY / 2.0
        //print("HalfDeltaX=\(HalfDeltaX), HalfDeltaY=\(HalfDeltaY)")
        let Result = CGPoint(x: Left + HalfDeltaX, y: Top + HalfDeltaY)
        return (Result, DeltaX, DeltaY)
    }
    
    /// Returns the angle between the two passed points.
    /// - Parameter Point1: First point.
    /// - Parameter And: Second point.
    /// - Returns: Angle (in degrees) between the two passed points.
    public static func AngleBetween(_ Point1: CGPoint, And Point2: CGPoint) -> CGFloat
    {
        let Origin = CGPoint(x: Point2.x - Point1.x, y: Point2.y - Point1.y)
        let Bearings = atan2f(Float(Origin.y), Float(Origin.x))
        var BearingDegrees = Bearings.Degrees
        BearingDegrees = BearingDegrees > 0.0 ? BearingDegrees : (360.0 + BearingDegrees)
        return CGFloat(BearingDegrees)
    }
}
