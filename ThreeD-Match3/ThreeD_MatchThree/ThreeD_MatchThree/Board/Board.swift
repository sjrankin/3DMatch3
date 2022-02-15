//
//  Board.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/9/22.
//

import Foundation
import UIKit

class Board
{
    public weak var MainDelegate: SurfaceProtocol? = nil
    
    init(Extent: Int, Plane: BoardPlanes)
    {
        Width = Extent
        Height = Extent
        self.Extent = Extent
        self.Plane = Plane
        BoardMap = Array(repeating: Array(repeating: .Piece1, count: Extent), count: Extent)
    }
    
    var Width: Int = 0
    var Height: Int = 0
    var Extent: Int = 0
    var Plane: BoardPlanes = .A
    var TopSide: BoardSides = .Top
    var Active: Bool = false
    
    // MARK: - Board map and access.
    
    /// Holds the board of pieces for the surface.
    var BoardMap: [[Pieces]]? = nil
    
    /// Subscript access to the pieces on the board.
    /// - Parameter X: X coordinate of the piece.
    /// - Parameter Y: Y coordinate of the piece.
    /// - Returns: The piece at the specified coordinate.
    subscript(X: Int, Y: Int) -> Pieces
    {
        get
        {
            return GetPiece(X, Y)
        }
        set
        {
            SetPiece(X, Y, NewPiece: newValue)
        }
    }
    
    /// Point access to the pieces on the board.
    /// - Parameter Location: The point of the location to access.
    /// - Returns: The piece at the specified location.
    subscript(_ Location: IPoint) -> Pieces
    {
        get
        {
            return GetPiece(Location)
        }
        set
        {
            SetPiece(Location, NewPiece: newValue)
        }
    }
    
    func GetPiece2(_ X: Int, _ Y: Int) -> Pieces
    {
        guard let Delegate = MainDelegate else
        {
            Debug.FatalError("Delete not available in \(#function)")
        }
        if let Node = Delegate.GetVisualNode(At: IPoint(X, Y), On: Plane)
        {
            return Node.Piece
        }
        else
        {
            return .Empty
        }
    }
    
    func SetPiece2(_ X: Int, _ Y: Int, NewPiece: Pieces)
    {
        guard let Delegate = MainDelegate else
        {
            Debug.FatalError("Delete not available in \(#function)")
        }
        Delegate.RemoveNodeAt(Logical: IPoint(X, Y), On: Plane)
        Delegate.AddNewPiece(NewPiece, At: IPoint(X, Y), On: Plane)
    }
    
    /// Returns the piece in the board at the specified `X` and `Y` coordinates.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: The piece at the specified coordinate.
    func GetPiece(_ X: Int, _ Y: Int) -> Pieces
    {
        return BoardMap![X][Y]
    }
    
    /// Returns the piece in the board at the specified point.
    /// - Parameter PiecePoint: The coordinate of the piece.
    /// - Returns: The piece at the specified coordinate.
    func GetPiece(_ PiecePoint: IPoint) -> Pieces
    {
        return BoardMap![PiecePoint.X][PiecePoint.Y]
    }
    
    /// Assign a new piece in the board at the specified coordinate.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Parameter NewPiece: The piece to assign to the specified location.
    func SetPiece(_ X: Int, _ Y: Int, NewPiece: Pieces)
    {
        BoardMap![X][Y] = NewPiece
    }
    
    /// Assign a new piece in the board at the specified coordinate.
    /// - Parameter PiecePoint: The coordinate of the piece.
    /// - Parameter NewPiece: The piece to assign to the specified location.
    func SetPiece(_ PiecePoint: IPoint, NewPiece: Pieces)
    {
        BoardMap![PiecePoint.X][PiecePoint.Y] = NewPiece
    }
    
    /// Perform an initial populate of the board.
    /// - Parameter TheMap: Map of pieces to use to populate the board.
    /// - Parameter To: Determines the range of pieces to use to populate the board.
    /// - Parameter IncludeBlocks: If true, blocking pieces will be added.
    public static func InitialPopulate(_ TheMap: Board,
                                       To: Int = 6,
                                       IncludeBlocks: Bool = false)
    {
        var Population = [Pieces]()
        var Count = 0
        for SomePiece in Pieces.allCases
        {
            Population.append(SomePiece)
            Count = Count + 1
            if Count > To
            {
                break
            }
        }
        if IncludeBlocks
        {
            Population.append(.Block)
        }
        for X in 0 ..< TheMap.Width
        {
            for Y in 0 ..< TheMap.Height
            {
                let RandomPiece = Population.randomElement()!
                TheMap.SetPiece(X, Y, NewPiece: RandomPiece)
            }
        }
    }
    
    /// Replace pieces in the board with a specified piece. Used for test pattern insertion and not
    /// intended for use in game play.
    /// - Note: No error checking is done.
    /// - Parameter AtX: The starting horizontal location of the new piece.
    /// - Parameter AtY: The starting vertical location of the new piece.
    /// - Parameter NewPiece: The new piece to insert.
    /// - Parameter PieceCount: Number of pieces to insert.
    /// - Parameter Horizontal: Determines orientation of the pattern of pieces.
    func ReplacePieces(AtX: Int, AtY: Int, NewPiece: Pieces,
                       PieceCount: Int, Horizontal: Bool)
    {
        if Horizontal
        {
            for X in AtX ..< AtX + PieceCount
            {
                SetPiece(X, AtY, NewPiece: NewPiece)
            }
        }
        else
        {
            for Y in AtY ..< AtY + PieceCount
            {
                SetPiece(AtX, Y, NewPiece: NewPiece)
            }
        }
        //update visual board here
    }
    
    /// Shift a column of pieces down.
    /// - Note: This function will leave gaps at the top of the column. Each gap is filled
    ///                   with `.Empty`.
    /// - Warning: Throws a fatal error if `To` is out of range or if `From` is greater or equal to `To`.
    /// - Parameter Column: The column which will be shifted.
    /// - Parameter From: Where the shift will start in the column. If the value in `From` is
    ///                                         greater or equal to the value in `To`,
    ///                                         a fatal error will be thrown.
    /// - Parameter To: The target row.
    func ShiftColumn(_ Column: Int, From Source: Int, To Row: Int)
    {
        if Row < 0 || Row > Height - 1
        {
            Debug.FatalError("Row out of range: (\(Row))")
        }
        if Source >= Row
        {
            Debug.FatalError("From[\(Source)] >= To[\(Row)]")
        }
        var Target = Row
        for ActionRow in stride(from: Source, to: 0, by: -1)
        {
            let PieceToMove = GetPiece(Column, ActionRow)
            SetPiece(Column, Target, NewPiece: PieceToMove)
            Target = Target - 1
        }
    }
    
    func FillMap() -> [IPoint]
    {
        let FMap = [IPoint]()
        
        return FMap
    }
    
    /// Returns the first non-empty row in the specified column.
    func FirstNonEmptyRowIn(Column: Int, After Row: Int = 0) -> Int?
    {
        for Y in Row ..< Height - 1
        {
            if GetPiece(Column, Y) == .Empty
            {
                return Y
            }
        }
        return nil
    }
    
    /// Determines if a column has any gaps.
    func ColumnHasGaps(Column: Int) -> Bool
    {
        for Y in 0 ..< Height - 1
        {
            if GetPiece(Column, Y) == .Empty
            {
                return true
            }
        }
        return false
    }
    
    /// Returns the number of pieces in the board of a given type.
    /// - Parameter Piece: The number of this type of piece will be returned.
    /// - Returns: Number of instances of `Piece` pieces found in the board.
    func PieceCount(_ Piece: Pieces) -> Int
    {
        var Total = 0
        for X in 0 ..< Width
        {
            for Y in 0 ..< Height
            {
                if GetPiece(X, Y) == Piece
                {
                    Total = Total + 1
                }
            }
        }
        return Total
    }
    
    /// Return the ID of the node at the logical point.
    /// - Warning: Throws a fatal error if no node is found at the specified location.
    /// - Parameter At: The logical location of the node whose ID is returned.
    /// - Returns: ID of the visual node at the specified logical location.
    func GetIDOfNode(At: IPoint) -> UUID
    {
        if let Delegate = MainDelegate
        {
        return Delegate.GetVisualNodeID(At: At, On: Plane)
        }
        Debug.FatalError("No MainDelegate defined.")
    }
    
    func RemoveNodes(_ NodeList: [UUID])
    {
        MainDelegate?.RemoveNodes(NodeList, On: Plane)
    }
}

/// Test patterns used for deb ugging.
enum TestPatterns: String, CaseIterable
{
    /// Three pieces arranged horizontally.
    case Horizontal3 = "Horizontal3"
    /// Three pieces arranged vertically.
    case Vertical3 = "Vertical3"
    /// Four pieces arranged horizontally.
    case Horizontal4 = "Horizontal4"
    /// Four pieces arranged vertically.
    case Vertical4 = "Vertical4"
    /// Five pieces arranged horizontally.
    case Horizontal5 = "Horizontal5"
    /// Five pieces arranged vertically.
    case Vertical5 = "Vertical5"
    /// Horizontal in the pattern "x xx".
    case Horizontal_x_xx = "hx_xx"
    /// Vertical in the pattern "x xx"
    case Vertical_x_xx = "vx_xx"
    /// Horizontal in the pattern "xx x"
    case Horizontal_xx_x = "hxx_x"
    /// Vertical in the pattern "xx x"
    case Vertical_xx_x = "vxx_x"
    case Horizontal_xxux = "hxxux"
    case Vertical_xxux = "vxxux"
    case Horizontal_xuxx = "hxuxx"
    case Vertical_xuxx = "vxuxx"
}

/// Valid pieces. Actual visuals are defined elsewhere.
enum Pieces: String, CaseIterable
{
    /// Piece 1.
    case Piece1 = "Piece1"
    /// Piece 2.
    case Piece2 = "Piece2"
    /// Piece 3.
    case Piece3 = "Piece3"
    /// Piece 4.
    case Piece4 = "Piece4"
    /// Piece 5.
    case Piece5 = "Piece5"
    /// Piece 6.
    case Piece6 = "Piece6"
    /// Piece 7.
    case Piece7 = "Piece7"
    /// Piece 8.
    case Piece8 = "Piece8"
    /// Piece 9.
    case Piece9 = "Piece9"
    /// Piece 10.
    case Piece10 = "Piece10"
    /// Block piece - immoveable.
    case Block = "Block"
    /// Empty piece - used for game play calculations and not visuals.
    case Empty = "Empty"
}

/// Edges of a board.
enum BoardSides: String, CaseIterable
{
    case Top = "Top"
    case Right = "Right"
    case Bottom = "Bottom"
    case Left = "Left"
}

/// Board planes or sides. Determines which side of a cube a board resides on. Arbitrarily assigned
/// letters.
enum BoardPlanes: String, CaseIterable
{
    /// Side 1
    case A = "A"
    /// Side 2
    case B = "B"
    /// Side 3
    case C = "C"
    /// Side 4
    case D = "D"
    /// Side 5
    case E = "E"
    /// Side 6
    case F = "F"
}

enum PieceShapes: String, CaseIterable
{
    case Sphere = "Sphere"
    case Box = "Box"
    case Star = "Star"
    case Triangle = "Triangle"
}
