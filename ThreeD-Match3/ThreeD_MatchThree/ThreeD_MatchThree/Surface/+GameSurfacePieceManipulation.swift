//
//  +GameSurfacePieceManipulation.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit

extension GameSurface
{
    /// Determines if the passed point is within the currently expected range (defined as `0 ..< CommonExtent`).
    func IsValidPoint(_ PiecePoint: IPoint) -> Bool
    {
        return PiecePoint.IsInRange(0, CommonExtent - 1)
    }
    
    /// Determines if the two passed pieces can be swapped according to game rules.
    /// - Note: Pieces can be swapped if they are directly adjacent with each other and if swapping
    /// the pieces is legal according to game rules.
    /// - Parameter Piece1: First piece.
    /// - Parameter Piece2: Second piece.
    /// - Parameter On: The side where the board resides.
    /// - Returns: True if the two pieces can be swapped, false if not.
    func CanSwapPieces(_ Piece1: IPoint, _ Piece2: IPoint, On Plane: BoardPlanes) -> Bool
    {
        let CurrentBoard = GetBoard(On: Plane)
        return CurrentBoard.CanSwapPieces(Piece1, Piece2)
    }
    
    /// Swap the pieces at the two specified points. By the time control reaches here, this function
    /// assumes the locations have been validated.
    /// - Parameter Piece1: Location of the first piece.
    /// - Parameter Piece2: Location of the second piece.
    /// - Parameter On: Determines the board where to swap the pieces.
    func SwapPieces(_ Piece1: IPoint, _ Piece2: IPoint, On Plane: BoardPlanes)
    {
        let CurrentBoard = GetBoard(On: Plane)
        CurrentBoard.SwapPieces(Piece1, Piece2)
    }
    
    /// Try to swap two pieces. Validates the passed points first.
    /// - Parameter Piece1: Location of the first piece.
    /// - Parameter Piece2: Location of the second piece.
    /// - Parameter On: Determines which board where the swap will take place.
    /// - Returns: True on success, false on error (invalid locations).
    func TrySwapPieces(Piece1: IPoint, Piece2: IPoint, On Plane: BoardPlanes) -> Bool
    {
        let CurrentBoard = GetBoard(On: Plane)
        return CurrentBoard.TrySwapPieces(Piece1, Piece2)
    }
}
