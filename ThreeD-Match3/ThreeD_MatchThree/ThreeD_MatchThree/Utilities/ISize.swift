//
//  ISize.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/23/22.
//

import Foundation
import UIKit

/// Very simple size class for integers.
class ISize: Equatable, CustomDebugStringConvertible
{
    /// Initializer.
    /// - Parameter Width: Initial width value.
    /// - Parameter Height: Initial height value.
    /// - Parameter Other: If provided, initial ancillary size value.
    init(_ Width: Int, _ Height: Int, Other: ISize? = nil)
    {
        self.Width = Width
        self.Height = Height
        Ancillary = Other
    }
    
    /// Initializer.
    /// - Parameter Width: Initial width value.
    /// - Parameter Height: Initial height value.
    /// - Parameter Other: If provided, initial ancillary size value.
    init(Width: Int, Height: Int, Other: ISize? = nil)
    {
        self.Width = Width
        self.Width = Width
        Ancillary = Other
    }
    
    /// Initializer.
    /// - Parameter Both: Initial value to assign to both `Width` and `Height`.
    /// - Parameter Other: If provided, initial ancillary size value.
    init(_ Both: Int, Other: ISize? = nil)
    {
        self.Width = Both
        self.Height = Both
        Ancillary = Other
    }
    
    /// Return the extent of the size. "Extent" is the value returned if both `Width` and `Height`
    /// are the same.
    var Extent: Int
    {
        if Width == Height
        {
            return Width
        }
        return 0
    }
    
    /// Width value. Defaults to `0`.
    var Width: Int = 0
    
    /// Height Value. Defaults to `0`.
    var Height: Int = 0
    
    /// Ancillary size. Defaults to `nil`.
    var Ancillary: ISize? = nil
    
    // MARK: - Equatable implementation.
    
    /// `ISize` equality function.
    static func == (lhs: ISize, rhs: ISize) -> Bool
    {
        return lhs.Width == rhs.Width && lhs.Height == rhs.Height
    }
    
    /// `ISize` inequality function.
    static func != (lhs: ISize, rhs: ISize) -> Bool
    {
        return !(lhs == rhs)
    }
    
    // MARK: - CustomDebugStringConvertible implementation.
    
    /// Prints a pretty string of the contents of the class.
    var debugDescription: String
    {
        return "(\(Width),\(Height))"
    }
}

