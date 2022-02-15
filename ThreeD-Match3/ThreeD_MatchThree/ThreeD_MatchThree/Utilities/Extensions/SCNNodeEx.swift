//
//  SCNNodeEx.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit
import SceneKit

/// Extended `SCNNode` class with extra meta-data.
class SCNNodeEx: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter With: Assigned ID of the node.
    init(With ID: UUID)
    {
        super.init()
        NodeID = ID
    }
    
    /// Initializer.
    /// - Parameter geometry: Shape of the node.
    /// - Parameter Shape: Shape identifier. Defaults to `.Sphere`.
    init(geometry: SCNGeometry?, Shape: PieceShapes = .Sphere)
    {
        super.init()
        self.geometry = geometry
        self.Shape = Shape
    }
    
    /// Required.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    // MARK: - New meta data.
    
    /// ID of the node. Assigned as instantiation time but can be overridden either by directly assigning a
    /// value or by the `init(UUID)` creation call.
    var NodeID: UUID = UUID()
    
    /// Tag value. Defaults to `nil`.
    var Tag: Any? = nil
    
    /// For piece nodes only: the plane the piece is assigned to. May change over the course of a game.
    var Plane: BoardPlanes = .A

    /// The shape of the piece (for pieces only). May change over the course of the game.
    var Shape: PieceShapes = .Sphere
    
    /// The current logical piece.
    var Piece: Pieces = .Piece1
    
    /// Logical X coordinate.
    var LogicalX: Int = 0
    
    /// Logical Y coordinate.
    var LogicalY: Int = 0
    
    // MARK: New functionality.
    
    /// Set the logical point.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    func SetLogicalPoint(_ X: Int, _ Y: Int)
    {
        LogicalX = X
        LogicalY = Y
    }
    
    /// Get or set child nodes cast to `SCNNodeEx`. When getting, any node that cannot be converted to
    /// `SCNNodeEx` is not returned.
    var ChildNodesEx: [SCNNodeEx]
    {
        get
        {
            let All = childNodes
            var Results = [SCNNodeEx]()
            for Node in All
            {
                if let Converted = Node as? SCNNodeEx
                {
                    Results.append(Converted)
                }
            }
            return Results
        }
        set
        {
            for NewNode in newValue
            {
                self.addChildNode(NewNode)
            }
        }
    }
    
    /// Source color for alternating colors.
    var AlternateColorSource: UIColor = UIColor.white
    /// Destiniation color for alternating colors.
    var AlternateColorDestination: UIColor = UIColor.black
    /// Determines which color to use.
    var AlternateColorFirst = true
    
    /// Change the color of the node periodically.
    /// - Parameter From: First color.
    /// - Parameter To: Second color.
    /// - Parameter Every: Frequency of the color change, in seconds.
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
    
    /// Quick and dirty way to set the color the the first material.
    /// - Parameter Color: The color to assign to the diffuse surface of the first material.
    func SetMaterialColor(_ Color: UIColor)
    {
        self.geometry!.firstMaterial!.diffuse.contents = Color
    }
    
    /// Swap the logical coordinates of the instance node and the passed node.
    /// - Parameter With: The other node to swap coordinates with.
    func SwapLogicalCoordinates(With Other: SCNNodeEx)
    {
        swap(&LogicalX, &Other.LogicalX)
        swap(&LogicalY, &Other.LogicalY)
    }
}
