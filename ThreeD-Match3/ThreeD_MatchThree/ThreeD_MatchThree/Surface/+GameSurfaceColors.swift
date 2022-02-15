//
//  +GameSurfaceColors.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit

extension GameSurface
{
    //MARK: - Color-related functions.
    
    /// Return a color for the specified piece.
    /// - Parameter SomePiece: The piece whose color will be returned.
    /// - Returns: Color for the specified piece.
    func ColorFor(_ SomePiece: Pieces) -> UIColor
    {
        switch SomePiece
        {
            case .Piece1:
                return UIColor.red
                
            case .Piece2:
                return UIColor.green
                
            case .Piece3:
                return UIColor.blue
                
            case .Piece4:
                return UIColor.systemCyan
                
            case .Piece5:
                return UIColor.systemPurple
                
            case .Piece6:
                return UIColor.systemYellow
                
            case .Piece7:
                return UIColor.RoseGold
                
            case .Piece8:
                return UIColor.InternationalOrange
                
            case .Piece9:
                return UIColor.Apricot
                
            case .Piece10:
                return UIColor.BlackGray
                
            default:
                return UIColor.black
        }
    }
    
    /// Returns a random color. One of six random colors is returned.
    /// - Returns: Random color.
    func RandomColor() -> UIColor
    {
        switch Int.random(in: 0 ..< 6)
        {
            case 0:
                return UIColor.red
                
            case 1:
                return UIColor.green
                
            case 2:
                return UIColor.blue
                
            case 3:
                return UIColor.systemCyan
                
            case 4:
                return UIColor.systemPurple
                
            case 5:
                return UIColor.systemYellow
                
            default:
                return UIColor.black
        }
    }
}
