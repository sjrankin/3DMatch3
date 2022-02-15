//
//  SideManager.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/22/22.
//

import Foundation
import UIKit
import SceneKit

/// Manages one side of the cube.
class SideManager
{
    /// `SideManager` initializer.
    /// - Parameter For: Determines the side of the parent cube being managed.
    /// - Parameter HorizontalPieces: The width of the side in number of pieces.
    /// - Parameter VerticalPieces: The height of the side in number of pieces.
    /// - Parameter HorizontalPhysical: Width of the side in `SceneKit` units.
    /// - Parameter VerticalPhysical: Height of the side in `SceneKit` units.
    /// - Parameter Parent: The parent box/cube shape where all of the boards live.
    init(For Side: BoardPlanes, HorizontalPieces: Int, VerticalPieces: Int,
         HorizontalPhysical: Double, VerticalPhysical: Double,
         Parent: SCNNode)
    {
        _Parent = Parent
        _ManagedSide = Side
        _HorizontalPieceCount = HorizontalPieces
        _VerticalPieceCount = VerticalPieces
        _SideIndex = SideManager.GetSideIndex(From: Side)
    }
    
    /// Holds the parent node.
    private var _Parent: SCNNode = SCNNode()
    /// Get the parent node of the side.
    var Parent: SCNNode
    {
        get
        {
            return _Parent
        }
    }
    
    /// Holds the side being managed.
    private var _ManagedSide: BoardPlanes = .A
    /// Get the managed side for the instance.
    var ManagedSide: BoardPlanes
    {
        get
        {
            return _ManagedSide
        }
    }
    
    /// Holds the physical width of the board.
    private var _SideWidth: Double = 8.0
    /// Get the physical width of the board.
    var SideWidth: Double
    {
        get
        {
            return _SideWidth
        }
    }
    
    /// Holds the physical height of the board.
    private var _SideHeight: Double = 8.0
    /// Get the physical height of the board.
    var SideHeight: Double
    {
        get
        {
            return _SideHeight
        }
    }
    
    /// Holds the number of pieces the board is wide.
    private var _HorizontalPieceCount: Int = 9
    /// Get the number of horizontal pieces. Defaults to `9`.
    var HorizontalPieceCount: Int
    {
        get
        {
            return _HorizontalPieceCount
        }
    }
    
    /// Holds the number of pieces the board is tall.
    private var _VerticalPieceCount: Int = 9
    /// Get the number of vertical pieces. Defaults to `9`.
    var VerticalPieceCount: Int
    {
        get
        {
            return _VerticalPieceCount
        }
    }
    
    /// Holds the side index.
    private var _SideIndex: Int = 0
    /// Get the side index - this is the side of the cube that this instance is responsible for managing.
    var SideIndex: Int
    {
        get
        {
            return _SideIndex
        }
    }
    
    /// Get or set the rule set. Each side can have different rules.
    var Rules: RuleSet = RuleSet()
    
    /// Returns a map of the pieces on the side.
    /// - Returns: Array (in `[X][Y]` order) of pieces on the side.
    func GetPieceMap() -> [[Pieces]]
    {
        var UIMap = Array(repeating: Array(repeating: Pieces.Piece1, count: HorizontalPieceCount), count: HorizontalPieceCount)
        for Y in 0 ..< VerticalPieceCount
        {
            for X in 0 ..< HorizontalPieceCount
            {
                guard let PieceNode = SideManager.GetVisualNode(At: IPoint(X, Y),
                                                                On: ManagedSide,
                                                                Parent) else
                                                                {
                                                                    Debug.FatalError("Error getting piece at \(IPoint(X, Y)) in \(#function).")
                                                                }
                UIMap[X][Y] = PieceNode.Piece
            }
        }
        return UIMap
    }
    
    /// Destructively moves the pieces in the passed list.
    /// - Note: This function will overwrite any piece at the new location.
    /// - Parameter PieceList: List of pieces to move and how. This array should have the lowest (Y order) pieces
    /// (closest to the bottom) at the start of the array.
    func MovePieces(_ PieceList: [MotionRecord])
    {
        for Motion in PieceList
        {
            guard let NodeToMove = SideManager.GetVisualNode(With: Motion.ID, Parent) else
            {
                Debug.FatalError("Error getting node with ID \(Motion.ID.uuidString)")
            }
            PlotPiece(NodeToMove, LogicalX: NodeToMove.LogicalX + Motion.MotionX,
                      LogicalY: NodeToMove.LogicalY + Motion.MotionY)
        }
    }
    
    func PlotPiece(_ Node: SCNNodeEx, LogicalX: Int, LogicalY: Int)
    {
        Node.SetLogicalPoint(LogicalX, LogicalY)
    }
    
    /// Plots the original set of pieces. Pieces are selected randomly.
    func InitializeSide()
    {
        let Size = CGSize(width: SideWidth, height: SideHeight)
        let PieceList: [Pieces] = [.Piece1, .Piece2, .Piece3, .Piece4, .Piece5]
        for Y in 0 ..< VerticalPieceCount
        {
            for X in 0 ..< HorizontalPieceCount
            {
                SideManager.AddNewPiece(PieceList,
                                        At: IPoint(X, Y),
                                        BoardSize: Size,
                                        PieceExtent: HorizontalPieceCount,
                                        On: ManagedSide,
                                        Parent)
            }
        }
    }
    
    /// Returns the board plane and that plane's edge that maps to the edge of the board for the current board plane's
    /// specified edge.
    /// - Note: The returned board plane is unmapped to the physical board plane.
    /// - Parameter Edge: The edge whose other board and that board's edge will be returned.
    /// - Returns: Tuple of the other board plane and that board plane's edge that maps to the edge passed to this
    /// function.
    func EdgeMapsTo(_ Edge: BoardSideMappings) -> (BoardPlanes, BoardSideMappings)
    {
        return SideManager.GetSideMapping(Source: ManagedSide, On: Edge)
    }
    
    // MARK: - Extension variables.
    
    var FlyTestTimer: Timer? = nil
}

/// Identifes the edges of a board.
enum BoardSideMappings: String, CaseIterable
{
    /// Top edge.
    case Top = "Top"
    /// Left side.
    case Left = "Left"
    /// Bottom edge.
    case Bottom = "Bottom"
    /// Right side.
    case Right = "Right"
}

/// Defines how a piece will move.
struct MotionRecord
{
    /// The ID of the piece. The piece itself contains all needed information with respect to
    /// location and the like.
    let ID: UUID
    /// How far to move horizontally in local coordinates. Negative values move left, positive
    /// values move right, and `0` has no horizontal motion.
    let MotionX: Int
    /// How far to move vertical in local coordinates. Negative values move up, positive
    /// values move down, and `0` has no vertical motion.
    let MotionY: Int
}
