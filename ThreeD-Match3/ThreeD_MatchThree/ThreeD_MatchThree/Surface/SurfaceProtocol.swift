//
//  SurfaceProtocol.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit
import SceneKit

protocol SurfaceProtocol: AnyObject
{
    /// Update the specified plane visually. Called by boards when they change something.
    /// - Parameter Plane: The plane to update.
    func UpdatePlane(_ Plane: BoardPlanes)
    
    /// Return a visual piece node with the specified ID.
    /// - Parameter With: The ID of the node to return.
    /// - Returns: Node with the specified ID if found, `nil` if not found.
    func GetVisualNode(With ID: UUID) -> SCNNodeEx?
    
    /// Return a visual piece node at the specified logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: Node at the specified location location if found, `nil` if not found.
    func GetVisualNode(At: IPoint, On Side: BoardPlanes) -> SCNNodeEx?

    /// Return all nodes on a given surface side.
    /// - Parameter On: The side whose nodes will be returned.
    /// - Returns: Array of all nodes on the specified side.
    func GetVisualNodes(On Side: BoardPlanes) -> [SCNNodeEx]
    
    /// Return the ID of a visual piece at the specified logical location.
    /// - Warning: Throws a fatal error if the node is not found at the logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: ID of the node at the specified logical location.
    func GetVisualNodeID(At: IPoint, On Side: BoardPlanes) -> UUID
    
    /// Return the ID of a visual piece at the specified logical location.
    /// - Parameter At: The logical point on the side.
    /// - Parameter On: The side of the surface.
    /// - Returns: ID of the node at the specified logical location. `Nil` returned if not found.
    func TryGetVisualNodeID(At: IPoint, On Side: BoardPlanes) -> UUID?
    
    /// Remove the nodes (both from the parent node and visually) in the passed list.
    /// - Parameter NodeList: The list of nodes to remove.
    /// - Parameter On: The side of the surface. Identifies the specific board.
    func RemoveNodes(_ NodeList: [UUID], On: BoardPlanes)
    
    /// Visual and logically move pieces as directed by `MoveList`.
    /// - Parameter MoveList: Moved the specified nodes in the specified `Y` direction.
    /// - Parameter On: The plane of the board.
    func MovePieces(_ MoveList: [(Logical: IPoint, YDelta: Int, ID: UUID)],
                    On Side: BoardPlanes)
    
    /// Create an array of pieces for the current user interface.
    /// - Warning: Throwns a fatal error when unable to retrieve a piece from the UI.
    /// - Parameter Side: Determines which side is used to create the map.
    /// - Returns: Two-dimensional array of pieces for the specified side.
    func GetMapFromUI(_ Side: BoardPlanes) -> [[Pieces]]
    
    /// Remove the node with the passed logical coordinate from the game surface.
    /// - Note: If the node is not found, no action is taken.
    /// - Parameter Logical: The logical location of the node on a plane.
    /// - Parameter On: The plane where the node is located.
    func RemoveNodeAt(Logical Point: IPoint, On Plane: BoardPlanes)
    
    /// Create a coordinate on a given board for a piece.
    /// - Parameter SomeSide: Determines the board where the piece will reside.
    /// - Parameter SurfaceDistance: The distance from the center of the scene to the surface of the board.
    /// - Parameter CellColumn: The piece's X coordinate on the board.
    /// - Parameter CellRow: The piece's Y coordinate on the board.
    /// - Parameter Width: The width of the board in SceneKit units.
    /// - Parameter Height: The height of the board in SceneKit units.
    /// - Returns: Coordinate to use to place the piece on the board.
    func GetPieceCoordinate(SomeSide: BoardPlanes, SurfaceDistance: Double,
                            CellColumn: Double, CellRow: Double,
                            Width: Double, Height: Double) -> SCNVector3

    /// Generate a random piece limited by the passed constant.
    /// - Parameter Max: The largest ordinal for the piece to be returned.
    /// - Parameter IncludeBlocks: If true, include blocking pieces.
    /// - Returns: Random piece.
    func GetRandomPiece(_ Max: Int, IncludeBlocks: Bool) -> Pieces
    
    /// Add a new piece to the surface.
    /// - Note: If an existing point is already present at the passed logical location, it must
    /// be removed first.
    /// - Parameter PieceType: The type of piece.
    /// - Parameter At: The logical location of the piece.
    /// - Parameter On: The side where the piece will initially be placed.
    func AddNewPiece(_ PieceType: Pieces, At: IPoint, On: BoardPlanes)
}
