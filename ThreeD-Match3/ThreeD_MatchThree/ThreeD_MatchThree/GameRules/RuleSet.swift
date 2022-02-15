//
//  RuleSet.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/22/22.
//

import Foundation

/// Defines rules for a single side on the game shape.
/// - Note: Rules may apply across boards but not necessarily the same both ways.
class RuleSet
{
    /// Get or set the pieces that are valid. The board is not changed if this is changed unless the board is reset.
    var PieceSet: [Pieces] = [.Piece1, .Piece2, .Piece3, .Piece4, .Piece5]
    
    var _GravitationDirection: [BoardSideMappings] = [.Bottom]
    /// Get or set gravity's direction. If more than one direction is specified, pieces will fall towards the closest
    /// edge on the given board. Duplicate directions are ignored.
    var GravitationDirection: [BoardSideMappings]
    {
        get
        {
            return _GravitationDirection
        }
        set
        {
            let Unique = Set<BoardSideMappings>(newValue)
            _GravitationDirection = Array(Unique)
        }
    }
    
    /// Determines what the source is for new pieces during game play.
    var NewPieceSource: NewPieceAppearance = .FromTopAdjacentSide
    
    /// Determines where pieces that fall off the bottom of a board go.
    var OldPieceDestination: OldPieceDisappearance = .ToAdjacentBottomBoard
    
    /// Holds a list of which sides support multi-board matching.
    private var _ValidSideMatches: [BoardSideMappings] = [.Top, .Bottom, .Left, .Right]
    /// Get or set the array of sides that support matching pieces across sides.
    var ValidSideMatches: [BoardSideMappings]
    {
        get
        {
            return _ValidSideMatches
        }
        set
        {
            let Unique = Set<BoardSideMappings>(newValue)
            _ValidSideMatches = Array(Unique)
        }
    }
}

/// Where new pieces come from.
enum NewPieceAppearance
{
    /// Pieces come from the the board that is adjacent to the top-most edge of the current board.
    case FromTopAdjacentSide
    /// Pieces fall in from the top edge but are randomly sourced, not from the adjacent board.
    case DropFromTop
}

/// Determines where pieces go once they reach the bottom.
enum OldPieceDisappearance
{
    /// Pieces are stationary and do not fall.
    case Stationary
    /// Pieces disappear at the logical bottom of the board (but do not move to other boards).
    case LogicalBottom
    /// Pieces disappear at the logical bottom of the board and move to the adjacent bottom board.
    case ToAdjacentBottomBoard
}
