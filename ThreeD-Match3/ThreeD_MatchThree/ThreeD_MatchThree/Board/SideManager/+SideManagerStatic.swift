//
//  +SideManagerStatic.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/22/22.
//

import Foundation
import UIKit
import SceneKit

extension SideManager
{
    // MARK: - Static functions and data.
    
    /// Returns the board (in terms of cube sides) and edge of the board that maps to the passed board and edge. Useful
    /// for wrapping around pieces.
    /// - Parameter Source: The source board plane.
    /// - Parameter On: The source board edge.
    /// - Returns: Tuple with the target board plane and the target board plane edge that is adjacent to the passed data.
    public static func GetSideMapping(Source Side: BoardPlanes, On Edge: BoardSideMappings) -> (BoardPlanes, BoardSideMappings)
    {
        switch Side
        {
            case .A:
                switch Edge
                {
                    case .Top:
                        return (.B, .Bottom)
                        
                    case .Left:
                        return (.F, .Right)
                        
                    case .Bottom:
                        return (.D, .Top)
                        
                    case .Right:
                        return (.E, .Left)
                }
                
            case .B:
                switch Edge
                {
                    case .Top:
                        return (.C, .Top)
                        
                    case .Left:
                        return (.F, .Top)
                        
                    case .Bottom:
                        return (.A, .Top)
                        
                    case .Right:
                        return (.E, .Left)
                }
                
            case .C:
                switch Edge
                {
                    case .Top:
                        return (.B, .Top)
                        
                    case .Left:
                        return (.E, .Left)
                        
                    case .Bottom:
                        return (.D, .Bottom)
                        
                    case .Right:
                        return (.F, .Left)
                }
                
            case .D:
                switch Edge
                {
                    case .Top:
                        return (.A, .Bottom)
                        
                    case .Left:
                        return (.F, .Bottom)
                        
                    case .Bottom:
                        return (.C, .Bottom)
                        
                    case .Right:
                        return (.E, .Bottom)
                }
                
            case .E:
                switch Edge
                {
                    case .Top:
                        return (.B, .Right)
                        
                    case .Left:
                        return (.A, .Right)
                        
                    case .Bottom:
                        return (.D, .Right)
                        
                    case .Right:
                        return (.D, .Left)
                }
                
            case .F:
                switch Edge
                {
                    case .Top:
                        return (.B, .Left)
                        
                    case .Left:
                        return (.C, .Right)
                        
                    case .Bottom:
                        return (.D, .Left)
                        
                    case .Right:
                        return (.A, .Left)
                }
        }
        Debug.FatalError("Invalid Plane/Edge combination in \(#function)")
    }
    
    /// Returns the geometry index of the cube side based on the mapping of the originally passed side to a physical mapping.
    /// - Parameter From: The side to translate to the cube side index. *Do not apply `SurfaceMapping` to
    /// this parameter prior to calling this function.*
    /// - Returns: The parent cube's geometry index.
    public static func GetSideIndex(From Side: BoardPlanes) -> Int
    {
        let Mapped = SideManager.SurfaceMapping[Side]!
        let Index = SideManager.SideIndexMap[Mapped]!
        return Index
    }
    
    /// Map from logical side planes to physical side planes.
    public static let SurfaceMapping: [BoardPlanes: BoardPlanes] =
    [
        .A: .A,
        .B: .C,
        .C: .B,
        .D: .D,
        .E: .E,
        .F: .F
    ]
    
    /// Map from physical side planes to parent cube geometry indices.
    public static let SideIndexMap: [BoardPlanes: Int] =
    [
        .A: 0,
        .B: 4,
        .C: 2,
        .D: 5,
        .E: 1,
        .F: 3
    ]
    
    /// Create a coordinate on a given board for a piece.
    /// - Parameter SomeSide: Determines the board where the piece will reside.
    /// - Parameter SurfaceDistance: The distance from the center of the scene to the surface of the board.
    /// - Parameter LogicalX: The piece's X coordinate on the board.
    /// - Parameter LogicalY: The piece's Y coordinate on the board.
    /// - Parameter Width: The width of the board in SceneKit units.
    /// - Parameter Height: The height of the board in SceneKit units.
    /// - Returns: Coordinate to use to place the piece on the board.
    public static func GetPieceCoordinate(SomeSide: BoardPlanes,
                                          SurfaceDistance: Double,
                                          LogicalX: Double,
                                          LogicalY: Double,
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
                X = LogicalX
                Y = LogicalY
                X = X - (Width / 2.0)
                Y = Y - (Height / 2.0)
                
            case .B:
                //XY vary, -Z constant
                Z = -SurfaceDistance
                X = LogicalX
                Y = LogicalY
                X = X - (Width / 2.0)
                Y = Y - (Height / 2.0)
                
            case .C:
                //XZ vary, Y constant
                Y = SurfaceDistance
                X = LogicalX
                Z = LogicalY
                X = X - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .D:
                //XZ vary, -Y constant
                Y = -SurfaceDistance
                X = LogicalX
                Z = LogicalY
                X = X - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .E:
                //YZ vary, X constant
                X = SurfaceDistance
                Y = LogicalX
                Z = LogicalY
                Y = Y - (Width / 2.0)
                Z = Z - (Height / 2.0)
                
            case .F:
                //YZ vary, -X constant
                X = -SurfaceDistance
                Y = LogicalX
                Z = LogicalY
                Y = Y - (Width / 2.0)
                Z = Z - (Height / 2.0)
        }
        
        return SCNVector3(X, Y, Z)
    }
    
    /// Update the pieces on the board.
    /// - Note: This function uses the contents of `PieceMap` for updating the visuals.
    public static func UpdateSide()
    {
        
    }
    
    /// Plot a game piece on the parent shape.
    /// - Parameter Node: The node to plot. This function assumes the node is fully formed. Location information will
    /// be calculated here and applied to the node.
    /// - Parameter Parent: The parent shape where the node will be plotted.
    /// - Parameter Plane: The parent surface side where the piece will be placed.
    /// - Parameter LogicalX: The logical X coordinate of the piece.
    /// - Parameter LogicalY: The logical Y coordinate of the piece.
    public static func PlotPiece(_ Node: SCNNodeEx, Parent: SCNNode,
                                 Plane: BoardPlanes,
                                 LogicalX: Int, LogicalY: Int)
    {
        
    }
    
    /// Return a visual piece node with the specified ID.
    /// - Parameter With: The ID of the node to return.
    /// - Parameter Surface: The parent 3D node.
    /// - Returns: Node with the specified ID if found, `nil` if not found.
    public static func GetVisualNode(With ID: UUID, _ Surface: SCNNode) -> SCNNodeEx?
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
    /// - Parameter Surface: The parent 3D node.
    /// - Returns: Node at the specified location location if found, `nil` if not found.
    public static func GetVisualNode(At: IPoint, On Side: BoardPlanes,
                                     _ Surface: SCNNode) -> SCNNodeEx?
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
    
    /// Determines if a node exists at the logical point on the specified side.
    /// - Parameter At: The local logical point on the specified side to look for a node.
    /// - Parameter On: The side of the 3D parent where to look for a node.
    /// - Parameter Surface: The 3D parent.
    /// - Returns: True if a node exists at the passed address, false if not.
    public static func VisualNodeExists(At: IPoint, On: BoardPlanes,
                                        _ Surface: SCNNode) -> Bool
    {
        return GetVisualNode(At: At, On: On, Surface) != nil
    }
    
    /// Return all nodes on a given surface side.
    /// - Parameter On: The side whose nodes will be returned.
    /// - Parameter Surface: The parent 3D node.
    /// - Returns: Array of all nodes on the specified side.
    public static func GetVisualNodes(On Side: BoardPlanes, _ Surface: SCNNode) -> [SCNNodeEx]
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
    /// - Parameter Surface: The parent 3D node.
    /// - Returns: ID of the node at the specified logical location.
    public static func GetVisualNodeID(At: IPoint, On Side: BoardPlanes,
                                       _ Surface: SCNNode) -> UUID
    {
        guard let Node = GetVisualNode(At: At, On: Side, Surface) else
        {
            Debug.FatalError("No node found at logical location \(At)")
        }
        return Node.NodeID
    }
    
    /// Return the ID of a visual piece at the specified logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Parameter Surface: Parent 3D node.
    /// - Returns: ID of the node at the specified logical location. `Nil` returned if not found.
    public static func TryGetVisualNodeID(At: IPoint, On Side: BoardPlanes,
                                          _ Surface: SCNNode) -> UUID?
    {
        guard let Node = GetVisualNode(At: At, On: Side, Surface) else
        {
            print("No node for \(At.X),\(At.Y)")
            return nil
        }
        return Node.NodeID
    }
    
    /// Remove the nodes (both from the parent node and visually) in the passed list.
    /// - Parameter NodeList: The list of nodes to remove.
    /// - Parameter On: The side where the node lives.
    /// - Parameter Surface: The parent 3D node.
    public static func RemoveNodes(_ NodeList: [UUID], On: BoardPlanes, _ Surface: SCNNode)
    {
        for ID in NodeList
        {
            guard let Node = GetVisualNode(With: ID, Surface) else
            {
                Debug.FatalError("Unable to find visual node with ID \(ID.uuidString)")
            }
            let FadeOut = SCNAction.fadeOut(duration: 0.2)
            let Remove = SCNAction.removeFromParentNode()
            let Sequence = SCNAction.sequence([FadeOut, Remove])
            Node.runAction(Sequence)
        }
    }
    
    /// Make a piece fly away from it's side. Used for debugging right now.
    /// - Parameter Side: Identifies the plane where the piece lives.
    /// - Parameter X:  Identifies the local logical horizontal coordinate.
    /// - Parameter X:  Identifies the local logical vertical coordinate.
    /// - Parameter BoardSize: Size of the board in `SceneKit` units.
    /// - Parameter Extent: Extent of the pieces.
    /// - Parameter FlyDuration: How long the flight shoul take, in seconds.
    /// - Parameter Repopulate: If true, pieces that fly away will be repopulated.
    /// - Parameter RepopulateWhen: How long to wait before repopulating pieces that have flown away.
    /// - Parameter Surface: The parent 3D node.
    public static func PieceFly(_ Side: BoardPlanes, _ X: Int, _ Y: Int,
                                BoardSize: CGSize,
                                Extent: Int, FlyDuration: Double = 2.0,
                                _ Repopulate: Bool, _ RepopulateWhen: Double = 0.5,
                                _ Surface: SCNNode)
    {
        if let Piece = GetVisualNode(At: IPoint(X, Y), On: Side, Surface)
        {
            if Piece.Piece == .Empty
            {
                return
            }
            var ToX: CGFloat = 0.0
            var ToY: CGFloat = 0.0
            var ToZ: CGFloat = 0.0
            let FlyAwayDistance: CGFloat = 100.0
            switch Mapping[Side]!
            {
                case .A:
                    ToX = 0.0
                    ToY = 0.0
                    ToZ = FlyAwayDistance
                    
                case .B:
                    ToX = 0.0
                    ToY = FlyAwayDistance
                    ToZ = 0.0
                    
                case .C:
                    ToX = 0.0
                    ToY = 0.0
                    ToZ = -FlyAwayDistance
                    
                case .D:
                    ToX = 0.0
                    ToY = -FlyAwayDistance
                    ToZ = 0.0
                    
                case .E:
                    ToX = FlyAwayDistance
                    ToY = 0.0
                    ToZ = 0.0
                    
                case .F:
                    ToX = -FlyAwayDistance
                    ToY = 0.0
                    ToZ = 0.0
            }
            let FlyAway = SCNAction.move(to: SCNVector3(ToX, ToY, ToZ),
                                         duration: FlyDuration)
            let FadeAway = SCNAction.fadeOut(duration: FlyDuration)
            let FlyFade = SCNAction.group([FlyAway, FadeAway])
            let FlySequence = SCNAction.sequence([FlyFade, SCNAction.removeFromParentNode()])
            Piece.runAction(FlySequence)
            
            let Address = NodeAddress(Side: Side, X: X, Y: Y)
            let AllData = RemoveInfo(Address: Address,
                                     BoardSize: BoardSize,
                                     Parent: Surface,
                                     Extent: Extent)
            let FlyTestTimer = Timer(timeInterval: RepopulateWhen,
                                     target: self,
                                     selector: #selector(RepopulateBoard(timer:)),
                                     userInfo: AllData,
                                     repeats: false)
            RunLoop.main.add(FlyTestTimer, forMode: .common)
        }
    }
    
    /// Handler for the piece repopulate event.
    /// - Parameter timer: The timer that triggered this event. The `.userInfo` field contains information on
    /// which piece to repopulate.
    @objc static func RepopulateBoard(timer: Timer)
    {
        if let AllData = timer.userInfo as? RemoveInfo
        {
            let PieceList: [Pieces] = [.Piece1, .Piece2, .Piece3, .Piece4, .Piece5]
            let Address = AllData.Address
            AddNewPiece(PieceList,
                        At: IPoint(Address.X, Address.Y),
                        BoardSize: AllData.BoardSize,
                        PieceExtent: AllData.Extent,
                        On: Address.Side, AllData.Parent)
        }
        else
        {
            print("Address is not NodeAddress")
        }
    }
    
    /// Returns the geometry for the specified piece.
    /// - Parameter For: The piece type whose geometry is returned.
    /// - Parameter Size: The size of the piece. Which fields in `Size` are used depends on the value of `For`.
    /// - Returns: Geometry defining the shape of the piece.
    public static func MakePieceShape(For: Pieces, Size: CGSize) -> SCNGeometry
    {
        return SCNSphere(radius: Size.width)
    }
    
    /// Create a new piece. Assign attributes and logical location.
    /// - Parameter ValidPieces: Set of valid pieces to chose amongst randomly.
    /// - Parameter X: Logical X position of the piece in the side's logical map.
    /// - Parameter Y: Logical Y position of the piece in the side's logical map.
    /// - Parameter BoardWidth: Width of the board in `SceneKit` units.
    /// - Parameter BoardHeight: Height of the board in `SceneKit` units.
    /// - Parameter Side: The side of the parent 3D node.
    public static func GenerateNewPiece(_ ValidPieces: [Pieces], X: Int, Y: Int,
                                        BoardWidth: Double, BoardHeight: Double,
                                        Side: BoardPlanes) -> SCNNodeEx
    {
        if ValidPieces.count < 1
        {
            Debug.FatalError("No valid piece set passed to \(#function)")
        }
        
        let Offset = BoardWidth * 0.1
        let CellExtent = (BoardWidth - Offset) / Double(9)
        let Radius = CellExtent * 0.45
        
        let PieceType = ValidPieces.randomElement()!
        let Shape = MakePieceShape(For: PieceType, Size: CGSize(width: Radius, height: 0.0))
        let PieceNode = SCNNodeEx(geometry: Shape)
        PieceNode.Plane = Side
        PieceNode.LogicalX = X
        PieceNode.LogicalY = Y
        PieceNode.Piece = PieceType
        PieceNode.geometry!.firstMaterial!.diffuse.contents = PieceColor(For: PieceType)
        return PieceNode
    }
    
    /// Standard map of color to piece type.
    public static var PieceColors: [Pieces: UIColor] =
    [
        .Piece1: UIColor.systemYellow,
        .Piece2: UIColor.systemTeal,
        .Piece3: UIColor.systemPurple,
        .Piece4: UIColor.systemMint,
        .Piece5: UIColor.systemRed,
        .Piece6: UIColor.systemBrown,
        .Piece7: UIColor.OrangePeel,
        .Piece8: UIColor.AzukiIro,
        .Piece9: UIColor.Gold,
        .Piece10: UIColor.BerkeleyBlue,
        .Empty: UIColor.clear,
        .Block: UIColor.black
    ]
    
    /// Returns a color for the specified game piece type. Uses `PieceColors` as the source for colors.
    /// - Parameter For: The type of game piece whose color will be returned.
    /// - Returns: Color for the specified game piece. If the game piece is not found, `.white` is returned.
    public static func PieceColor(For Piece: Pieces) -> UIColor
    {
        return PieceColors[Piece] ?? UIColor.white
    }
    
    /// Add a new piece to the specified side.
    /// - Note: The piece's location is calculated here and placed into the parent here.
    /// - Parameter NewPiece: Set of pieces to choose from. Determines shape and color.
    /// - Parameter At: The logical local coordinate of the new piece on the side.
    /// - Parameter BoardSize: The size of the board in `SceneKit` units.
    /// - Parameter PieceExtent: The extent of the pieces - assumed to be the same size horizontally and vertically.
    /// - Parameter On: The side where the piece will initially be placed.
    /// - Parameter Surface: The 3D parent surface that will hold the piece.
    public static func AddNewPiece(_ NewPiece: [Pieces], At: IPoint, BoardSize: CGSize,
                                   PieceExtent: Int, On: BoardPlanes, _ Surface: SCNNode)
    {
        let NewPiece = GenerateNewPiece(NewPiece,
                                        X: At.X,
                                        Y: At.Y,
                                        BoardWidth: BoardSize.width,
                                        BoardHeight: BoardSize.height,
                                        Side: On)
        NewPiece.opacity = 0.0
        NewPiece.AlternateColor(From: UIColor.red, To: UIColor.systemYellow, Every: 0.5)
        #if false
        let Offset = BoardSize.width * 0.1
        let SideOffset = Offset / 2.0
        let CellExtent = (BoardSize.width - Offset) / Double(PieceExtent)
        let HalfCellExtent = CellExtent / 2.0
        let CellColumn = SideOffset + (Double(At.X) * CellExtent) + HalfCellExtent
        let CellRow = SideOffset + (Double((PieceExtent - 1) - At.Y) * CellExtent) + HalfCellExtent
        
        let Location = GetPieceCoordinate(SomeSide: On,
                                          SurfaceDistance: BoardSize.width / 2.0,
                                          LogicalX: CellColumn,
                                          LogicalY: CellRow,
                                          Width: BoardSize.width,
                                          Height: BoardSize.height)
        NewPiece.position = Location
        #else
        NewPiece.position = MakePieceCoordinate(At, On, BoardSize, PieceExtent)
#endif
        DispatchQueue.main.async
        {
            Surface.addChildNode(NewPiece)
            let FadeIn = SCNAction.fadeIn(duration: 0.075)
            NewPiece.runAction(FadeIn)
        }
    }
    
    /// Generate the physical coordinates of a piece with the passed logical coordinates.
    /// - Parameter At: The logical local coordinate of the new piece on the side.
    /// - Parameter On: The side where the piece will initially be placed.
    /// - Parameter BoardSize: The size of the board in `SceneKit` units.
    /// - Parameter PieceExtent: The extent of the pieces - assumed to be the same size horizontally and vertically.
    public static func MakePieceCoordinate(_ At: IPoint, _ On: BoardPlanes, _ BoardSize: CGSize,
                                           _ PieceExtent: Int) -> SCNVector3
    {
        let Offset = BoardSize.width * 0.1
        let SideOffset = Offset / 2.0
        let CellExtent = (BoardSize.width - Offset) / Double(PieceExtent)
        let HalfCellExtent = CellExtent / 2.0
        let CellColumn = SideOffset + (Double(At.X) * CellExtent) + HalfCellExtent
        let CellRow = SideOffset + (Double((PieceExtent - 1) - At.Y) * CellExtent) + HalfCellExtent
        
        let Location = GetPieceCoordinate(SomeSide: On,
                                          SurfaceDistance: BoardSize.width / 2.0,
                                          LogicalX: CellColumn,
                                          LogicalY: CellRow,
                                          Width: BoardSize.width,
                                          Height: BoardSize.height)
        return Location
    }
    
    /// Update the position of a piece on a given side. For moving pieces to different sides, see `UpdatePieceSide`.
    /// - Parameter Node: The piece to move on the same side.
    /// - Parameter NewPosition: The new position of the piece on the side. If an existing piece is already there, it
    /// is deleted and removed.
    /// - Parameter On: The side where the moving takes place.
    /// - Parameter LogicalSize: The extent of the board in piece units.
    /// - Parameter BoardSize: The size of the board in `SceneKit` units.
    /// - Parameter Surface: The parent 3D surface.
    public static func UpdatePieceLocation(_ Node: SCNNodeEx, NewPosition: IPoint,
                                           On: BoardPlanes, LogicalSize: ISize,
                                           BoardSize: CGSize, Surface: SCNNode)
    {
        
    }
    
    /// Swap two visual nodes' locations.
    /// - Parameter Node1ID: The ID of the first node.
    /// - Parameter Node2ID: The ID of the second node.
    /// - Parameter BoardSize: The size (in `SceneKit` units of the board).
    /// - Parameter BoardExtent: The extent of pieces on the board.
    /// - Parameter Surface: The parent 3D node.
    public static func Swap(_ Node1ID: UUID, _ Node2ID: UUID, BoardSize: CGSize,
                            BoardExtent: Int, Surface: SCNNode)
    {
        guard let Node1 = GetPiece(With: Node1ID, From: Surface) else
        {
            Debug.FatalError("Error retrieving Node1.")
        }
        guard let Node2 = GetPiece(With: Node2ID, From: Surface) else
        {
            Debug.FatalError("Error retrieving Node2.")
        }
        let Node1Pos = Node1.position
        let Node2Pos = Node2.position
        let Move1 = SCNAction.move(to: Node1Pos, duration: 0.5)
        Node2.runAction(Move1)
        
        var XOffset: Float = 0.0
        var YOffset: Float = 0.0
        var ZOffset: Float = 0.0
        switch Mapping[Node1.Plane]!
        {
            case .A:
                ZOffset = 1.0
            case .C:
                ZOffset = -1.0
                
            case .B:
                YOffset = 1.0
            case .D:
                YOffset = -1.0
                
            case .E:
                XOffset = 1.0
            case .F:
                XOffset = -1.0
        }
        let UpPosition = SCNVector3(x: Node1.position.x + XOffset,
                                    y: Node1.position.y + YOffset,
                                    z: Node1.position.z + ZOffset)
        let Move1Up = SCNAction.move(to: UpPosition, duration: 0.2)
        let Move1Down = SCNAction.move(to: Node2Pos, duration: 0.3)
        let Move1Sequence = SCNAction.sequence([Move1Up, Move1Down])
        Node1.runAction(Move1Sequence)
        Node1.SwapLogicalCoordinates(With: Node2)
        /*
        let JumpAction = SCNAction.customAction(duration: 0.5)
        {
            [weak self] Node, ElapsedPercent in
            let Angle = 180.0 * Double(ElapsedPercent)
            let Radians = Angle.Radians
        }
        
        //use sCNAction.custom action to move in arcs
        
        func AlternateColor(From: UIColor, To: UIColor, Every: Double)
        {
            AlternateColorSource = From
            AlternateColorDestination = To
            let AltColor = SCNAction.customAction(duration: Every)
            {
                [weak self] Node, ElapsedTime in
                if ElapsedTime == 1.0
                {
                    self!.AlternateColorFirst = !self!.AlternateColorFirst
                    if self!.AlternateColorFirst
                    {
                        Node.geometry!.firstMaterial!.diffuse.contents = self!.AlternateColorSource
                    }
                    else
                    {
                        Node.geometry!.firstMaterial!.diffuse.contents = self!.AlternateColorDestination
                    }
                }
            }
            let Forever = SCNAction.repeatForever(AltColor)
            self.runAction(Forever)
        }
         */
    }
    
    /// Determines if swapping the positions of `Node1` and `Node2` is valid. Nodes must be logically next
    /// to each other.
    /// - Warning: Currently, nodes must be on the same side to be swapped.
    /// - Parameter Node1: First node.
    /// - Parameter Node2: Second node.
    /// - Returns: True if the nodes are next to each (but not diagonally next to each other), false if not.
    public static func ValidSwap(_ Node1: SCNNodeEx, _ Node2: SCNNodeEx) -> Bool
    {
        //for now, all nodes must be on the same plane
        if Node1.Plane != Node2.Plane
        {
            return false
        }
        let XDelta = abs(Node1.LogicalX - Node2.LogicalX)
        let YDelta = abs(Node1.LogicalY - Node2.LogicalY)
        if XDelta > 1 || YDelta > 1
        {
            return false
        }
        if XDelta == 1 && YDelta == 0
        {
            return true
        }
        if XDelta == 0 && YDelta == 1
        {
            return true
        }
        return false
    }
    
    /// Updates the position and side of a piece. For moving pieces within a given side, see `UpdatePieceLocation`.
    /// - Warning: Throws a fatal error if the new side is the same as the existing side.
    /// - Parameter Node: The piece to move to a new side.
    /// - Parameter ToSide: The target side for the piece. If this side is the same as the current side, a fatal error
    /// is thrown.
    /// - Parameter NewLogicalPosition: The new logical position in local coordinates of the piece. If a piece is
    /// already there, it is deleted and removed.
    /// - Parameter BoardSize: The size of the board in `SceneKit` units.
    public static func UpdatePieceSide(_ Node: SCNNodeEx, ToSide: BoardPlanes,
                                       NewLogicalPosition: IPoint, BoardSize: CGSize,
                                       Surface: SCNNode)
    {
        
    }
    
    /// Maps logical sides to actual sides based on geometry indices on the cube.
    public static let Mapping: [BoardPlanes: BoardPlanes] =
    [
        .A: .A,
        .B: .C,
        .C: .B,
        .D: .D,
        .E: .E,
        .F: .F
    ]
    
    /// Dictionary of managed sides. The keys are logical, not actual.
    public static var ManagedSides = [BoardPlanes: SideManager]()
    
    /// Create all of the managed sides for the parent cube/box.
    /// - Parameter Parent: The parent 3D node.
    /// - Parameter HorizontalExtent: Number of horizontal pieces.
    /// - Parameter VerticalExtent: Numbrer of vertical pieces.
    /// - Parameter HorizontalSize: Width of the side in `SceneKit` units.
    /// - Parameter VerticalSize: Height of the side in `SceneKit` units.
    public static func CreateManagedSides(Parent: SCNNode,
                                         HorizontalExtent: Int, VerticalExtent: Int,
                                         HorizontalSize: Double, VerticalSize: Double)
    {
        for Plane in BoardPlanes.allCases
        {
            let SMan = SideManager(For: Plane,
                                   HorizontalPieces: HorizontalExtent,
                                   VerticalPieces: VerticalExtent,
                                   HorizontalPhysical: HorizontalSize,
                                   VerticalPhysical: VerticalSize,
                                   Parent: Parent)
            SMan.InitializeSide()
            ManagedSides[Plane] = SMan
        }
    }
    
    // MARK: - Piece access
    
    /// Get a piece at the specified logical local coordinates on the specified side.
    /// - Parameter On: The side of the board of the piece.
    /// - Parameter X: The local horizontal coordinate.
    /// - Parameter Y: The local vertical coordinate.
    /// - Parameter From: The 3D node that holds the nodes.
    /// - Returns: The node with the specified logical coordinates if found, nil if not found.
    public static func GetPiece(On Side: BoardPlanes, _ X: Int, _ Y: Int,
                                From Surface: SCNNode) -> SCNNodeEx?
    {
        for Node in Surface.childNodes
        {
            if let XNode = Node as? SCNNodeEx
            {
                if XNode.LogicalX == X && XNode.LogicalY == Y
                {
                    return XNode
                }
            }
        }
        return nil
    }
    
    /// Get a piece at the specified logical local coordinates on the specified side.
    /// - Parameter On: The side of the board of the piece.
    /// - Parameter Point: The local coordinates.
    /// - Parameter From: The 3D node that holds the nodes.
    /// - Returns: The node with the specified logical coordinates if found, `nil` if not found.
    public static func GetPiece(On Side: BoardPlanes, _ Point: IPoint,
                                From Surface: SCNNode) -> SCNNodeEx?
    {
        return GetPiece(On: Side, Point.X, Point.Y, From: Surface)
    }
    
    /// Return the piece type at the logical address.
    /// - Parameter On: The side where the piece lives.
    /// - Parameter X: The logical horizontal coordinate.
    /// - Parameter Y: The logical vertical coordinate.
    /// - Parameter From: The 3D node where that holds the pieces.
    /// - Returns: The type of piece at the logical address if found, nil if not found.
    public static func GetPieceType(On Side: BoardPlanes, _ X: Int, _ Y: Int,
                                    From Surface: SCNNode) -> Pieces?
    {
        for Node in Surface.childNodes
        {
            if let XNode = Node as? SCNNodeEx
            {
                if XNode.LogicalX == X && XNode.LogicalY == Y
                {
                    return XNode.Piece
                }
            }
        }
        return nil
    }
    
    /// Return the piece type at the logical address.
    /// - Parameter On: The side where the piece lives.
    /// - Parameter Point: The logical coordinate.
    /// - Parameter From: The 3D node where that holds the pieces.
    /// - Returns: The type of piece at the logical address if found, nil if not found.
    public static func GetPieceType(On Side: BoardPlanes, _ Point: IPoint,
                                    From Surface: SCNNode) -> Pieces?
    {
        return GetPieceType(On: Side, Point.X, Point.Y, From: Surface)
    }
    
    /// Get the node with the specified ID.
    /// - Parameter With: The ID of the node to return.
    /// - Parameter From: The 3D node that holds the nodes.
    /// - Returns: The node with the specified ID on success, nil if not found.
    public static func GetPiece(With ID: UUID, From Surface: SCNNode) -> SCNNodeEx?
    {
        for Node in Surface.childNodes
        {
            if let XNode = Node as? SCNNodeEx
            {
                if XNode.NodeID == ID
                {
                    return XNode
                }
            }
        }
        return nil
    }
}

/// Encapsulates the address of a playing piece node. This is intended to be
/// a one-time reading value.
struct NodeAddress
{
    /// Side of the cube.
    let Side: BoardPlanes
    /// Local logical horizontal coordinate.
    let X: Int
    /// Local logical vertical coordinate.
    let Y: Int
}

struct RemoveInfo
{
    let Address: NodeAddress
    let BoardSize: CGSize
    let Parent: SCNNode
    let Extent: Int
}
