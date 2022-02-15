//
//  +GameSurfaceProtocolHandler.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit
import SceneKit

extension GameSurface: SurfaceProtocol
{
    //MARK: - SurfaceProtocol implementations.
    
    /// Update the specified plane visually.
    /// - Parameter Plane: The plane to update.
    func UpdatePlane(_ Plane: BoardPlanes)
    {
        UpdateBoard(GetBoard(On: Plane),
                    CountX: 9, CountY: 9, Width: 8.0, Height: 8.0)
    }
    
    /// Return a visual piece node with the specified ID.
    /// - Parameter With: The ID of the node to return.
    /// - Returns: Node with the specified ID if found, `nil` if not found.
    func GetVisualNode(With ID: UUID) -> SCNNodeEx?
    {
        for SubNode in Surface.childNodes
        {
            if let PieceNode = SubNode as? SCNNodeEx
            {
                if PieceNode.NodeID == ID
                {
                    return PieceNode
                }
            }
        }
        return nil
    }
    
    /// Return a visual piece node at the specified logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: Node at the specified location location if found, `nil` if not found.
    func GetVisualNode(At: IPoint, On Side: BoardPlanes) -> SCNNodeEx?
    {
        for SubNode in Surface.childNodes
        {
            if let PieceNode = SubNode as? SCNNodeEx
            {
                if PieceNode.Plane == Side &&
                    PieceNode.LogicalX == At.X &&
                    PieceNode.LogicalY == At.Y
                {
                    return PieceNode
                }
            }
        }
        return nil
    }
    
    /// Return all nodes on a given surface side.
    /// - Parameter On: The side whose nodes will be returned.
    /// - Returns: Array of all nodes on the specified side.
    func GetVisualNodes(On Side: BoardPlanes) -> [SCNNodeEx]
    {
        var PlaneNodes = [SCNNodeEx]()
        for SubNode in Surface.childNodes
        {
            if let PieceNode = SubNode as? SCNNodeEx
            {
                if PieceNode.Plane == Side
                {
                    PlaneNodes.append(PieceNode)
                }
            }
        }
        return PlaneNodes
    }
    
    /// Return the ID of a visual piece at the specified logical location.
    /// - Warning: Throws a fatal error if the node is not found at the logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: ID of the node at the specified logical location.
    func GetVisualNodeID(At: IPoint, On Side: BoardPlanes) -> UUID
    {
        guard let Node = GetVisualNode(At: At, On: Side) else
        {
            Debug.FatalError("No node found at logical location \(At)")
        }
        return Node.NodeID
    }
    
    /// Return the ID of a visual piece at the specified logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: ID of the node at the specified logical location. `Nil` returned if not found.
    func TryGetVisualNodeID(At: IPoint, On Side: BoardPlanes) -> UUID?
    {
        guard let Node = GetVisualNode(At: At, On: Side) else
        {
            print("No node for \(At.X),\(At.Y)")
            return nil
        }
        return Node.NodeID
    }
    
    /// Remove the nodes (both from the parent node and visually) in the passed list.
    /// - Parameter NodeList: The list of nodes to remove.
    func RemoveNodes(_ NodeList: [UUID], On: BoardPlanes)
    {
        for ID in NodeList
        {
            guard let Node = GetVisualNode(With: ID) else
            {
                Debug.FatalError("Unable to find visual node with ID \(ID.uuidString)")
            }
            let FadeOut = SCNAction.fadeOut(duration: 0.2)
            let Remove = SCNAction.removeFromParentNode()
            let Sequence = SCNAction.sequence([FadeOut, Remove])
            Node.runAction(Sequence)
        }
    }
    
    /// Visual and logically move pieces as directed by `MoveList`.
    /// - Parameter MoveList: Moved the specified nodes in the specified `Y` direction.
    /// - Parameter On: The plane of the board.
    func MovePieces(_ MoveList: [(Logical: IPoint, YDelta: Int, ID: UUID)],
                    On Side: BoardPlanes)
    {
        let ToMove = MoveList.filter({$0.YDelta == 0})
        print("Dropping pieces: \(ToMove.count)")
        for SomeMotion in ToMove
        {
            print("SomeMotion.YDelta=\(SomeMotion.YDelta)")
            if SomeMotion.YDelta == 0
            {
                continue
            }
            guard let Node = GetVisualNode(With: SomeMotion.ID) else
            {
                Debug.FatalError("Unable to find visual node with ID \(SomeMotion.ID.uuidString)")
            }
            print("Moving piece at \(SomeMotion.Logical.X),\(SomeMotion.Logical.Y) to \(SomeMotion.Logical.X),\(SomeMotion.Logical.Y + SomeMotion.YDelta)")
            Node.SetLogicalPoint(SomeMotion.Logical.X,
                                 SomeMotion.Logical.Y + SomeMotion.YDelta)
            let NewVisualPoint = GetPieceCoordinate(SomeSide: Side,
                                                    SurfaceDistance: SurfaceWidth / 2.0,
                                                    CellColumn: Double(SomeMotion.Logical.X),
                                                    CellRow: Double(SomeMotion.Logical.Y + SomeMotion.YDelta),
                                                    Width: SurfaceWidth,
                                                    Height: SurfaceHeight)
            let DropAction = SCNAction.move(to: NewVisualPoint,
                                            duration: 1.0)
            Node.runAction(DropAction)
        }
    }
    
    /// Create an array of pieces for the current user interface.
    /// - Warning: Throwns a fatal error when unable to retrieve a piece from the UI.
    /// - Parameter Side: Determines which side is used to create the map.
    /// - Returns: Two-dimensional array of pieces for the specified side.
    func GetMapFromUI(_ Side: BoardPlanes) -> [[Pieces]]
    {
        var UIMap = Array(repeating: Array(repeating: Pieces.Piece1, count: SurfaceExtent), count: SurfaceExtent)
        for Y in 0 ..< SurfaceExtent
        {
            for X in 0 ..< SurfaceExtent
            {
                guard let PieceNode = GetVisualNode(At: IPoint(X, Y), On: Side) else
                {
                    Debug.FatalError("Error getting piece at \(IPoint(X, Y)) in \(#function).")
                }
                UIMap[X][Y] = PieceNode.Piece
            }
        }
        return UIMap
    }
    
    /// Remove the node with the passed logical coordinate from the game surface.
    /// - Note: If the node is not found, no action is taken.
    /// - Parameter Logical: The logical location of the node on a plane.
    /// - Parameter On: The plane where the node is located.
    func RemoveNodeAt(Logical Point: IPoint, On Plane: BoardPlanes)
    {
        if let SomeNode = GetVisualNode(At: Point, On: Plane)
        {
            SomeNode.removeFromParentNode()
        }
    }
    
    /// Generate a random piece limited by the passed constant.
    /// - Parameter Max: The largest ordinal for the piece to be returned.
    /// - Returns: Random piece.
    func GetRandomPiece(_ Max: Int, IncludeBlocks: Bool) -> Pieces
    {
        var Count = 0
        var Population = [Pieces]()
        for SomePiece in Pieces.allCases
        {
            Population.append(SomePiece)
            Count = Count + 1
            if Count > Max
            {
                break
            }
        }
        if IncludeBlocks
        {
            Population.append(.Block)
        }
        let RandomPiece = Population.randomElement()!
        return RandomPiece
    }
    
    /// Add a new piece to the surface.
    /// - Note: If an existing point is already present at the passed logical location, it must
    /// be removed first.
    /// - Parameter PieceType: The type of piece.
    /// - Parameter At: The logical location of the piece.
    /// - Parameter On: The side where the piece will initially be placed.
    func AddNewPiece(_ PieceType: Pieces, At: IPoint, On: BoardPlanes)
    {
        //print("AddNewPiece: Width=\(SurfaceWidth), Height=\(SurfaceHeight)")
        let CurrentPiece = PieceType
        let Offset = SurfaceWidth * 0.1
        let SideOffset = Offset / 2.0
        let CellExtent = (SurfaceWidth - Offset) / Double(SurfaceExtent)
        //print("AddNewPiece: CellExtent=\(CellExtent)")
        let Radius = CellExtent * 0.45
        let SurfaceDistance = SurfaceWidth / 2.0
        
        let PieceColor = ColorFor(CurrentPiece)
        let CellColumn = SideOffset + (Double(At.X) * CellExtent) + (CellExtent / 2.0)
        let CellRow = SideOffset + (Double((9 - 1) - At.Y) * CellExtent) + (CellExtent / 2.0)
        //print("AddNewPiece: CellColumn=\(CellColumn), CellRow=\(CellRow)")
        
        let PieceNodeShape = SCNSphere(radius: Radius)
        let PieceNode = SCNNodeEx(geometry: PieceNodeShape)
        PieceNode.Plane = On
        PieceNode.LogicalX = At.X
        PieceNode.LogicalY = At.Y
        PieceNode.Piece = CurrentPiece
        let MappedSide = Mapping[On]!
        let PiecePosition = GetPieceCoordinate(SomeSide: MappedSide,//On,
                                               SurfaceDistance: SurfaceDistance,
                                               CellColumn: Double(At.X),
                                               CellRow: Double(At.Y),
                                               Width: SurfaceWidth,
                                               Height: SurfaceHeight)
        
        
        print("AddNewPiece: PiecePosition=\(PiecePosition.PrettyPrint())")
        PieceNode.castsShadow = true
        PieceNode.categoryBitMask = 0x10
        PieceNodeShape.firstMaterial?.diffuse.contents = PieceColor
        PieceNode.position = PiecePosition
        Surface.addChildNode(PieceNode)
    }
    
    /// Create a coordinate on a given board for a piece.
    /// - Parameter SomeSide: Determines the board where the piece will reside.
    /// - Parameter SurfaceDistance: The distance from the center of the scene to the surface of the board.
    /// - Parameter CellColumn: The piece's X coordinate on the board.
    /// - Parameter CellRow: The piece's Y coordinate on the board.
    /// - Parameter Width: The width of the board in SceneKit units.
    /// - Parameter Height: The height of the board in SceneKit units.
    /// - Returns: Coordinate to use to place the piece on the board.
    func GetPieceCoordinate(SomeSide: BoardPlanes,
                            SurfaceDistance: Double,
                            CellColumn: Double,
                            CellRow: Double,
                            Width: Double,
                            Height: Double) -> SCNVector3
    {
        var X: Double = 0.0
        var Y: Double = 0.0
        var Z: Double = 0.0
        
        switch SomeSide
        {
            case .A:
                //XY vary, Z constant
                Z = SurfaceDistance
                X = CellColumn
                Y = CellRow
                X = X - (Width / 2.0)
                Y = Y - (Height / 2.0)
                
            case .B:
                //XY vary, -Z constant
                Z = -SurfaceDistance
                X = CellColumn
                Y = CellRow
                X = X - (Width / 2.0)
                Y = Y - (Height / 2.0)
                
            case .C:
                //XZ vary, Y constant
                Y = SurfaceDistance
                X = CellColumn
                Z = CellRow
                X = X - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .D:
                //XZ vary, -Y constant
                Y = -SurfaceDistance
                X = CellColumn
                Z = CellRow
                X = X - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .E:
                //YZ vary, X constant
                X = SurfaceDistance
                Y = CellColumn
                Z = CellRow
                Y = Y - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .F:
                //YZ vary, -X constant
                X = -SurfaceDistance
                Y = CellColumn
                Z = CellRow
                Y = Y - (Width / 2.0)
                Z = Z - (Height / 2.0)
        }
        
        return SCNVector3(X, Y, Z)
    }
}
