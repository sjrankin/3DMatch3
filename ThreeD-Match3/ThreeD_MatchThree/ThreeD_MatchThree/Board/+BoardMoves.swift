//
//  +BoardMoves.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit

extension Board
{
    // MARK: - Point validation.
    /// Determines if the passed point is within the currently expected range (defined as `0 ..< CommonExtent`).
    func IsValidPoint(_ PiecePoint: IPoint) -> Bool
    {
        return PiecePoint.IsInRange(0, Extent - 1)
    }
    
    // MARK: - Piece moving.
    
    /// Move a piece from one point to another. This function updates the UI as well as the board map.
    /// - Note: This function is normally called by a `Swap` function which keeps tracks of pieces
    /// and points to move. This function overwrites
    /// - Parameter From: Source location of the piece to move.
    /// - Parameter To: Destination location of the piece to move.
    /// - Parameter Closure: Closure called when the point is moved and finalized. If there were no errors,
    /// `true` is passed to the first parameter, otherwise, `false` is passed. If either point is invalid, no
    /// motion will take place.
    func MovePiece(From: IPoint, To: IPoint, _ Closure: ((Bool) -> ())? = nil)
    {
        if !IsValidPoint(From) || !IsValidPoint(To)
        {
            Closure?(false)
            return
        }
        let MoveMe = GetPiece(From)
        SetPiece(To, NewPiece: MoveMe)
        Closure?(true)
    }
    
    func ExecuteSwap(_ Piece1: IPoint, _ Piece2: IPoint)
    {
        
    }
    
    // MARK: - Piece swapping.
    
    /// Determines if the two passed pieces can be swapped according to game rules.
    /// - Note: Pieces can be swapped if they are directly adjacent with each other and if swapping
    /// the pieces is legal according to game rules.
    /// - Parameter Piece1: First piece.
    /// - Parameter Piece2: Second piece.
    /// - Returns: True if the two pieces can be swapped, false if not.
    func CanSwapPieces(_ Piece1: IPoint, _ Piece2: IPoint) -> Bool
    {
        //Check for point validity.
        if !IsValidPoint(Piece1) || !IsValidPoint(Piece2)
        {
            return false
        }
        if Piece1 == Piece2
        {
            return false
        }
        //Check for adjacency.
        if Piece1.X != Piece2.X && Piece1.Y != Piece2.Y
        {
            return false
        }
        if Piece1.X == Piece2.X
        {
            //Check for top and bottom.
            if abs(Piece1.Y - Piece2.Y) > 1
            {
                return false
            }
        }
        if Piece1.Y == Piece2.Y
        {
            //Check for left and right.
            if abs(Piece1.X - Piece2.X) > 1
            {
                return false
            }
        }
        //Check for game rules.
        return false
    }
    
    /// Swap the pieces at the two specified points. By the time control reaches here, this function
    /// assumes the locations have been validated.
    /// - Parameter Piece1: Location of the first piece.
    /// - Parameter Piece2: Location of the second piece.
    func SwapPieces(_ Piece1: IPoint, _ Piece2: IPoint)
    {
        
    }
    
    /// Try to swap two pieces. Validates the passed points first.
    /// - Parameter Piece1: Location of the first piece.
    /// - Parameter Piece2: Location of the second piece.
    /// - Returns: True on success, false on error (invalid locations).
    func TrySwapPieces(_ Piece1: IPoint, _ Piece2: IPoint) -> Bool
    {
        if CanSwapPieces(Piece1, Piece2)
        {
            SwapPieces(Piece1, Piece2)
        }
        else
        {
            return false
        }
        return true
    }
    
    /// Create a list of how far each piece must drop to pack the bottom of the board.
    /// - Returns: Array of tuples. Each tuple has a point addressing the piece to drop
    /// the distance the piece must drop, and the ID of the node to drop.
    func MakeDropList() -> [(IPoint, Int, UUID)]
    {
        guard let Delegate = MainDelegate else
        {
            Debug.FatalError("No delegate assigned in \(#function).")
        }
        var DList = [(IPoint, Int, UUID)]()
        for X in 0 ..< Extent
        {
            var DropDistance = 0
            for Y in stride(from: Extent - 1, through: 0, by: -1)
            {
                if let PieceNode = Delegate.GetVisualNode(At: IPoint(X, Y), On: Plane)
                {
                    let Piece = GetPiece(X, Y)
                    if Piece == .Empty
                    {
                        DropDistance = DropDistance + 1
                        continue
                    }
                    else
                    {
                        let NodeLocation = IPoint(X, Y)
                        if let NodeID = Delegate.TryGetVisualNodeID(At: NodeLocation, On: Plane)
                        {
                            print("Node found at \(NodeLocation): DropDistance=\(DropDistance)")
                            DList.append((NodeLocation, DropDistance, NodeID))
                        }
                        else
                        {
                            print("No node found at \(NodeLocation)")
                        }
                    }
                }
            }
        }
        return DList
    }
    
    func PrintDropMap(_ DList: [(IPoint, Int, UUID)])
    {
        for Y in 0 ..< Extent
        {
            var RowString = ""
            for X in 0 ..< Extent
            {
                let DropCount = GetDropIn(DList, At: IPoint(X,Y))
                RowString = RowString + "\(DropCount)"
            }
            print("\(RowString)")
        }
    }
    
    /// Returns a drop point for a given location in the passed list of points to drop.
    /// - Parameter DList: The drop list created by `MakeDropList`.
    /// - Parameter At: The address of the point whose drop count will be returned.
    /// - Returns: Number of locations the point must drop. If the specified point is not
    /// found in the list, `0` is returned.
    func GetDropIn(_ DList: [(IPoint, Int, UUID)], At: IPoint) -> Int
    {
        for SomeDrop in DList
        {
            if SomeDrop.0 == At
            {
                return SomeDrop.1
            }
        }
        return 0
    }
    
    /// Drops pieces to the lowest possible location. Does not check for collapsable patterns.
    func DropPieces()
    {
        let DropList = MakeDropList()
        
        //Update the visual map.
        //        MainDelegate?.UpdatePlane(Plane)
        MainDelegate?.MovePieces(DropList, On: Plane)
        #if true
        //Update the logical map.
        for Y in stride(from: Extent - 1, through: 0, by: -1)
        {
            for X in 0 ..< Extent
            {
                let DropBy = GetDropIn(DropList, At: IPoint(X, Y))
                if DropBy > 0
                {
                    MovePiece(From: IPoint(X, Y), To: IPoint(X, Y + DropBy))
                    SetPiece(IPoint(X, Y), NewPiece: .Empty)
                }
            }
        }
        #endif
    }
    
    /// Drops pieces to the lowest possible location. Does not check for collapsable patterns.
    func DropPiecesX()
    {
        print("Map before dropping")
        print("\(DebugMap)\n")
        var UpdateCount = 0
        for X in 0 ..< Extent
        {
            var FoundEmpty = false
            var Y = Extent - 1
            var SourcePoint: IPoint = IPoint(0,0)
            while Y >= 0
            {
                if GetPiece(X, Y) == .Empty && !FoundEmpty
                {
                    FoundEmpty = true
                    SourcePoint = IPoint(X, Y)
                }
                if GetPiece(X, Y) != .Empty && FoundEmpty
                {
                    FoundEmpty = false
                    MovePiece(From: SourcePoint, To: IPoint(X, Y))
                    SetPiece(SourcePoint, NewPiece: .Empty)
                    UpdateCount = UpdateCount + 1
                }
                Y = Y - 1
            }
        }
        
        print("Map after dropping")
        print("\(DebugMap)")
        MainDelegate?.UpdatePlane(Plane)
    }
}
