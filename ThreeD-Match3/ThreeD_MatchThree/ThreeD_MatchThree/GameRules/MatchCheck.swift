//
//  MatchCheck.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/9/22.
//

import Foundation
import UIKit

/// Closure type used in `CheckForMatches`. First parameter is number of matching pieces found.
/// Second parameter is the type of piece found. Third parameter is the horizontal coordinate. Fourth
/// parameter is the vertical coordinatel. Fifth parameter is the horizontal flag.
typealias FoundCheckClosure = ((Int, Pieces, Int, Int, Bool) -> ())

typealias FoundIDsToRemove = (([UUID]) -> ())

/// Handles rules related to pattern matching
class MatchCheck
{
    // Checks for x*xx, xx*x, xx_, and _xx, horizontally and vertically.
    //                        __x      x__
    public static func CheckForAvailableMoves(On Target: Board) -> Bool
    {
        return false
    }
    
    public static func CheckForMatches2(On Target: Board,
                                       _ Closure: FoundIDsToRemove? = nil)
    {
        var IDList = [UUID]()
        for X in 0 ..< Target.Width
        {
            for Y in 0 ..< Target.Height
            {
                let CurrentPiece = Target.GetPiece(X, Y)
                if CurrentPiece == .Empty
                {
                    continue
                }
                //Horizontal checks
                //Check if next four are the same
                if X < Target.Width - 5 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece &&
                        Target.GetPiece(X + 3, Y) == CurrentPiece &&
                        Target.GetPiece(X + 4, Y) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 1, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 2, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 3, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 4, Y)))
                        Closure?(IDList)
                    }
                }
                //Check if next three are the same
                if X < Target.Width - 4 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece &&
                        Target.GetPiece(X + 3, Y) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 1, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 2, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 3, Y)))
                        Closure?(IDList)
                    }
                }
                //Check if next two are the same
                if X < Target.Width - 3 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 1, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X + 2, Y)))
                        Closure?(IDList)
                    }
                }
                //Vertical checks
                //Check if next four are the same
                if Y < Target.Height - 5 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece &&
                        Target.GetPiece(X, Y + 3) == CurrentPiece &&
                        Target.GetPiece(X, Y + 4) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 1)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 2)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 3)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 4)))
                        Closure?(IDList)
                    }
                }
                //Check if next three are the same
                if Y < Target.Height - 4 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece &&
                        Target.GetPiece(X, Y + 3) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 1)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 2)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 3)))
                        Closure?(IDList)
                    }
                }
                //Check if next two are the same
                if Y < Target.Height - 3 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece
                    {
                        IDList.removeAll()
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 1)))
                        IDList.append(Target.GetIDOfNode(At: IPoint(X, Y + 2)))
                        Closure?(IDList)
                    }
                }
            }
        }
    }
    
    /// Look for patterns in the passed board that need to be removed, like three in a row.
    /// - Parameter On: The board to be checked for patterns to remove.
    /// - Parameter Closure: Called for each pattern found.
    public static func CheckForMatches(On Target: Board,
                                       _ Closure: FoundCheckClosure? = nil)
    {
        for X in 0 ..< Target.Width
        {
            for Y in 0 ..< Target.Height
            {
                let CurrentPiece = Target.GetPiece(X, Y)
                if CurrentPiece == .Empty
                {
                    continue
                }
                //Horizontal checks
                //Check if next four are the same
                if X < Target.Width - 5 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece &&
                        Target.GetPiece(X + 3, Y) == CurrentPiece &&
                        Target.GetPiece(X + 4, Y) == CurrentPiece
                    {
                        Closure?(5, CurrentPiece, X, Y, true)
                    }
                }
                //Check if next three are the same
                if X < Target.Width - 4 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece &&
                        Target.GetPiece(X + 3, Y) == CurrentPiece
                    {
                        Closure?(4, CurrentPiece, X, Y, true)
                    }
                }
                //Check if next two are the same
                if X < Target.Width - 3 + 1
                {
                    if Target.GetPiece(X + 1, Y) == CurrentPiece &&
                        Target.GetPiece(X + 2, Y) == CurrentPiece
                    {
                        Closure?(3, CurrentPiece, X, Y, true)
                    }
                }
                //Vertical checks
                //Check if next four are the same
                if Y < Target.Height - 5 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece &&
                        Target.GetPiece(X, Y + 3) == CurrentPiece &&
                        Target.GetPiece(X, Y + 4) == CurrentPiece
                    {
                        Closure?(5, CurrentPiece, X, Y, false)
                    }
                }
                //Check if next three are the same
                if Y < Target.Height - 4 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece &&
                        Target.GetPiece(X, Y + 3) == CurrentPiece
                    {
                        Closure?(4, CurrentPiece, X, Y, false)
                    }
                }
                //Check if next two are the same
                if Y < Target.Height - 3 + 1
                {
                    if Target.GetPiece(X, Y + 1) == CurrentPiece &&
                        Target.GetPiece(X, Y + 2) == CurrentPiece
                    {
                        Closure?(3, CurrentPiece, X, Y, false)
                    }
                }
            }
        }
    }
}
