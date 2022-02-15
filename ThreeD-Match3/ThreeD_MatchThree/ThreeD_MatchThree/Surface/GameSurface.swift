//
//  GameSurface.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/8/22.
//

import Foundation
import UIKit
import SceneKit

/// Interface between a virtual map of pieces and the actual user interface. Individual board manipulation
/// must be done through this class.
class GameSurface
{
    var Surface = SCNNode()
    let BGColors =
    [
        UIColor.Gold,
        UIColor.OrangePeel,
        UIColor.PrussianBlue,
        UIColor.AzukiIro,
        UIColor.Pistachio,
        UIColor.LightSkyBlue
    ]
    let DebugTextures =
    [
        "SurfaceA",
        "SurfaceE",
        "SurfaceC",
        "SurfaceF",
        "SurfaceB",
        "SurfaceD"
        /*
        "SurfaceA",
        "SurfaceB", //E
        "SurfaceC", //B
        "SurfaceD", //F
        "SurfaceE", //C
        "SurfaceF"  //D
         */
    ]
    
    var CommonExtent: Int = 9
    
    /// Initialize the game surface.
    /// - Note: [Different surface textures on cube](https://stackoverflow.com/questions/27509092/scnbox-different-colour-or-texture-on-each-face)
    /// - Parameter Parent: The parent user interface.
    /// - Parameter Extent: All boards have the same width and height - this value is the value for
    /// the width and hight in units of pieces.
    ///  - Parameter Width: Width of each side of the board in `SceneKit` units.
    ///  - Parameter Height: Height of each side of the board in `SceneKit` units.
    init(_ Parent: SCNView, Extent: Int,
         Width: Double, Height: Double)
    {
#if true
        let SideMaterials = DebugTextures.map
        {
            ImageName -> SCNMaterial in
            let Material = SCNMaterial()
            Material.diffuse.contents = UIImage(named: ImageName)
            Material.locksAmbientWithDiffuse = true
            Material.isDoubleSided = true
            return Material
        }
#else
        let SideMaterials = BGColors.map
        {
            BGColor -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = BGColor
            material.locksAmbientWithDiffuse = true
            material.isDoubleSided = true
            return material
        }
#endif
        let Materials = SideMaterials
        let Cube = SCNBox(width: Width, height: Height,
                          length: Width, chamferRadius: 0.3)
        Cube.chamferSegmentCount = 100
        Cube.materials = Materials
        Surface = SCNNode(geometry: Cube)
        Surface.position = SCNVector3(0, 0, 0)
        Parent.scene?.rootNode.addChildNode(Surface)
        /*
        ResetAllBoards(Extent: 9, MaxPiece: 4)
        SurfaceWidth = Width
        SurfaceHeight = Height
        SurfaceExtent = Extent
         */
    }
    
    var SurfaceWidth: Double = 0.0
    var SurfaceHeight: Double = 0.0
    var SurfaceExtent: Int = 0
    
    /// Remove all nodes on a given side.
    /// - Parameter From: The side whose nodes will be removed.
    func RemovePieces(From Side: BoardPlanes)
    {
        for SomeNode in Surface.childNodes
        {
            if let XNode = SomeNode as? SCNNodeEx
            {
                if XNode.Plane == Side
                {
                    XNode.removeFromParentNode()
                }
            }
        }
    }
    
    /// Update a single side/board. The map for the side is updated with the passed data, and the user
    /// interface is also updated.
    /// - Parameter Updated: The board that was updated. The board contains information that indicates the exact side to update.
    /// - Parameter CountX: Number of horizontal pieces.
    /// - Parameter CountY: Number of vertical pieces.
    /// - Parameter Width: Width of the parent user interface in `SceneKit` units.
    /// - Parameter Height: Height of the parent user interface in `SceneKit` units.
    func UpdateBoard(_ Updated: Board,
                     CountX: Int, CountY: Int, Width: Double,
                     Height: Double)
    {
        //let EmptyCount = Updated.PieceCount(.Empty)
        RemovePieces(From: Updated.Plane)
        ApplyMapToBoard(SurfaceMap: [Updated],
                        CountX: CountX, CountY: CountY,
                        Width: Width, Height: Height)
    }
    
    /// Remove the pieces with the IDs in the passed list.
    /// - Parameter DeleteList: List of piece IDs that will be removed.
    func RemovePieces(_ DeleteList: [UUID])
    {
        for DeleteID in DeleteList
        {
            for SubNode in Surface.childNodes
            {
                if let PieceNode = SubNode as? SCNNodeEx
                {
                    if PieceNode.NodeID == DeleteID
                    {
                        PieceNode.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    /// Apply an array of boards to the user interface.
    /// - Parameter SurfaceMap: The array of boards to update. Each board has data indicating which side. If multiple
    /// copies of the same side are passed, the actual view will be updated multiple times.
    /// - Parameter CountX: Number of horizontal pieces.
    /// - Parameter CountY: Number of vertical pieces.
    /// - Parameter Width: Width of the parent user interface in `SceneKit` units.
    /// - Parameter Height: Height of the parent user interface in `SceneKit` units.
    func ApplyMapToBoard(SurfaceMap: [Board],
                         CountX: Int, CountY: Int,
                         Width: Double, Height: Double)
    {
        let Offset = Width * 0.1
        let SideOffset = Offset / 2.0
        let CellExtent = (Width - Offset) / Double(CountX)
        let Radius = CellExtent * 0.45
        let SurfaceDistance = Width / 2.0
        
        for SomeSide in SurfaceMap
        {
            for Column in 0 ..< CountX
            {
                for Row in 0 ..< CountY
                {
                    let CurrentPiece = SomeSide.GetPiece(Column, Row)
                    if CurrentPiece == .Empty
                    {
                        continue
                    }
                    
                    let PieceColor = ColorFor(CurrentPiece)
                    let CellColumn = SideOffset + (Double(Column) * CellExtent) + (CellExtent / 2.0)
                    let CellRow = SideOffset + (Double((CountY - 1) - Row) * CellExtent) + (CellExtent / 2.0)
                    //print("ApplyMapToBoard: CellColumn=\(CellColumn), CellRow=\(CellRow)")
                    
                    let PieceNodeShape = SCNSphere(radius: Radius)
                    let PieceNode = SCNNodeEx(geometry: PieceNodeShape)
                    PieceNode.Plane = SomeSide.Plane
                    PieceNode.LogicalX = Column
                    PieceNode.LogicalY = Row
                    PieceNode.Piece = CurrentPiece
                    
                    let PiecePosition = GetPieceCoordinate(SomeSide: SomeSide.Plane,
                                                           SurfaceDistance: SurfaceDistance,
                                                           CellColumn: CellColumn,
                                                           CellRow: CellRow,
                                                           Width: Width,
                                                           Height: Height)
 
                    PieceNode.castsShadow = true
                    PieceNode.categoryBitMask = 0x10
                    PieceNodeShape.firstMaterial?.diffuse.contents = PieceColor
                    PieceNode.position = PiecePosition
                    Surface.addChildNode(PieceNode)
                }
            }
        }
        
        for SomeSide in BoardPlanes.allCases
        {
            let VisualSide = Mapping[SomeSide]!
            var LogicalTop = [SCNNodeEx]()
            switch SomeSide
            {
                case .A, .C, .D:
                    LogicalTop = PiecesAtLogicalY(0, Side: VisualSide)
                    
                case .B, .E, .F:
                    LogicalTop = PiecesAtLogicalY(SurfaceExtent - 1, Side: VisualSide)
            }
            for TopPiece in LogicalTop
            {
                TopPiece.AlternateColor(From: .white,
                                        To: SideColors[VisualSide]!,
                                        Every: 1.0)
            }
        }
    }
    
    let SideColors: [BoardPlanes: UIColor] =
    [
        .A: .yellow,
        .B: .green,
        .C: .red,
        .D: .blue,
        .E: .cyan,
        .F: .magenta
    ]
    
    let Mapping: [BoardPlanes: BoardPlanes] =
    [
        .A: .A,
        .B: .C,
        .C: .B,
        .D: .D,
        .E: .E,
        .F: .F
    ]
    
    func PiecesAtLogicalX(_ X: Int, Side: BoardPlanes) -> [SCNNodeEx]
    {
        var PieceList = [SCNNodeEx]()
        for Y in 0 ..< SurfaceExtent
        {
            guard let Node = GetVisualNode(At: IPoint(X, Y), On: Side) else
            {
                Debug.FatalError("Error getting visual node on side \(Side) at \(IPoint(X, Y)).")
            }
            PieceList.append(Node)
        }
        return PieceList
    }
    
    func PiecesAtLogicalY(_ Y: Int, Side: BoardPlanes) -> [SCNNodeEx]
    {
        var PieceList = [SCNNodeEx]()
        for X in 0 ..< SurfaceExtent
        {
            guard let Node = GetVisualNode(At: IPoint(X, Y), On: Side) else
            {
                Debug.FatalError("Error getting visual node on side \(Side) at \(IPoint(X, Y)).")
            }
            PieceList.append(Node)
        }
        return PieceList
    }
    
    //https://stackoverflow.com/questions/30064816/scenekit-animate-node-along-path
    func Explode()
    {
        
    }
    
    /// Reset all boards.
    /// - Parameter Extent: The width and height in pieces.
    /// - Parameter MaxPiece: Determines how many piece types to display.
    func ResetAllBoards(Extent: Int, MaxPiece: Int)
    {
        for SomeNode in Surface.childNodes
        {
            SomeNode.removeFromParentNode()
        }

        BoardList = [Board]()
        for SomePlane in BoardPlanes.allCases
        {
            let ThePlane = Board(Extent: Extent, Plane: SomePlane)
            ThePlane.MainDelegate = self
            Board.InitialPopulate(ThePlane, To: MaxPiece)
            BoardList.append(ThePlane)
        }
        
        ApplyMapToBoard(SurfaceMap: BoardList,
                        CountX: Extent, CountY: Extent,
                        Width: 8.0, Height: 8.0)
    }
    
    /// Contains all boards for the user interface.
    var _BoardList: [Board] = [Board]()
    /// Get or set the list of boards for the user interface.
    var BoardList: [Board]
    {
        get
        {
            return _BoardList
        }
        set
        {
            _BoardList = newValue
        }
    }
    
    /// Returns the board on the specified plane.
    /// - Warning: A fatal error is thrown if the plane cannot be found.
    /// - Parameter On: The board plane whose board will be returned.
    /// - Returns: The board on the specified plane.
    func GetBoard(On Side: BoardPlanes) -> Board
    {
        for SomeBoard in BoardList
        {
            if SomeBoard.Plane == Side
            {
                return SomeBoard
            }
        }
        Debug.FatalError("Board for side \(Side) not found.")
    }
    
    /// Derive a debug map for the pieces in the UI on the specified side.
    /// - Parameter Side: The side whose map will be returned.
    /// - Returns: Debug map of the side.
    func DeriveMapFromUI(_ Side: BoardPlanes) -> String
    {
        var Results = ""
        for Y in 0 ..< SurfaceExtent
        {
            for X in 0 ..< SurfaceExtent
            {
                guard let PieceNode = GetVisualNode(At: IPoint(X, Y), On: Side) else
                {
                    Debug.FatalError("Error getting piece at \(IPoint(X, Y)) from UI.")
                }
                Results.append(MapPieceToChar(PieceNode.Piece))
            }
            Results.append("\n")
        }
        return Results
    }
    
    func MapPieceToChar(_ Piece: Pieces) -> String
    {
        switch Piece
        {
            case .Piece1:
                return "A"
                
            case .Piece2:
                return "B"
                
            case .Piece3:
                return "C"
                
            case .Piece4:
                return "D"
                
            case .Piece5:
                return "E"
                
            case .Piece6:
                return "F"
                
            case .Piece7:
                return "G"
                
            case .Piece8:
                return "H"
                
            case .Piece9:
                return "I"
                
            case .Piece10:
                return "J"
                
            case .Block:
                return "Z"
                
            case .Empty:
                return " "
        }
    }
    
    func PieceFly(_ Side: BoardPlanes, _ X: Int, _ Y: Int,
                  _ Repopulate: Bool, _ RepopulateWhen: Double = 2.5)
    {
        if let Piece = GetVisualNode(At: IPoint(X, Y), On: Side)
        {
            if Piece.Piece == .Empty
            {
                return
            }
            var ToX: CGFloat = 0.0
            var ToY: CGFloat = 0.0
            var ToZ: CGFloat = 0.0
            switch Mapping[Side]!
            {
                case .A:
                    ToX = 0.0
                    ToY = 0.0
                    ToZ = 50.0
                    
                case .B:
                    ToX = 0.0
                    ToY = 50.0
                    ToZ = 0.0
                    
                case .C:
                    ToX = 0.0
                    ToY = 0.0
                    ToZ = -50.0
                    
                case .D:
                    ToX = 0.0
                    ToY = -50.0
                    ToZ = 0.0
                    
                case .E:
                    ToX = 50.0
                    ToY = 0.0
                    ToZ = 0.0
                    
                case .F:
                    ToX = -50.0
                    ToY = 0.0
                    ToZ = 0.0
            }
            let FlyAway = SCNAction.move(to: SCNVector3(ToX, ToY, ToZ),
                                         duration: RepopulateWhen * 0.85)
            let FlySequence = SCNAction.sequence([FlyAway, SCNAction.removeFromParentNode()])
            Piece.runAction(FlySequence)
            
            let Address = NodeAddress(Side: Side, X: X, Y: Y)
            let FlyTestTimer = Timer(timeInterval: RepopulateWhen,
                                     target: self,
                                     selector: #selector(RepopulateBoard(timer:)),
                                     userInfo: Address,
                                     repeats: false)
            RunLoop.main.add(FlyTestTimer, forMode: .common)
        }
    }
    
    var FlyTestTimer: Timer? = nil
    
    @objc func RepopulateBoard(timer: Timer)
    {
        if let Address = timer.userInfo as? NodeAddress
        {
            print("Repopulate at \(Address.X),\(Address.Y) on side \(Address.Side)")
            AddNewPiece(Pieces.allCases.randomElement()!,
                        At: IPoint(Address.X, Address.Y),
                        On: Address.Side)
        }
        else
        {
            print("Address is not NodeAddress")
        }
    }
}


