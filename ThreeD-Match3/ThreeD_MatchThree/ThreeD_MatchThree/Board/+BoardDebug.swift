//
//  +BoardDebug.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit

extension Board
{
    /// Returns a string of the current map.
    var DebugMap: String
    {
        get
        {
            let PieceMap: [Pieces: String] =
            [
                .Piece1: "A",
                .Piece2: "B",
                .Piece3: "C",
                .Piece4: "D",
                .Piece5: "E",
                .Piece6: "F",
                .Piece7: "G",
                .Piece8: "H",
                .Piece9: "I",
                .Piece10: "J",
                .Block: "Z",
                .Empty: " ",
            ]
            var Results = ""
            for Row in 0 ..< Height
            {
                for Column in 0 ..< Width
                {
                    let SomePiece = GetPiece(Column, Row)
                    let Token = PieceMap[SomePiece]!
                    Results.append(Token)
                }
                Results.append("\n")
            }
            return Results
        }
    }
    
    /// Inserts a test pattern in the board for debug usage.
    /// - Parameter Pattern: The pattern to insert.
    /// - Parameter With: The piece to use to populate the pattern.
    /// - Parameter Position: The initial position of the pattern. Positions that result
    /// in patterns exceeding the bounds of the board will immediately return without populating
    /// any pieces.
    func InsertTestPattern(_ Pattern: TestPatterns,
                           With Piece: Pieces,
                           Position: CGPoint)
    {
        if Position.x < 0 || Position.y < 0
        {
            print("X or Y is less than 0")
            return
        }
        if Int(Position.x) > Width - 1 || Int(Position.y) > Height - 1
        {
            print("X or Y is too big")
            return
        }
        switch Pattern
        {
            case .Horizontal3:
                if Int(Position.x) + 3 - 1 > Width - 1
                {
                    print("Bad position for horizontal 3 pattern")
                    return
                }
                for X in Int(Position.x) ..< Int(Position.x) + 3
                {
                    SetPiece(X, Int(Position.y), NewPiece: Piece)
                }
                
            case .Vertical3:
                if Int(Position.y) + 3 - 1 > Height - 1
                {
                    print("Bad position for vertical 3 pattern")
                    return
                }
                for Y in Int(Position.y) ..< Int(Position.y) + 3
                {
                    SetPiece(Int(Position.x), Y, NewPiece: Piece)
                }
                
            case .Horizontal4:
                if Int(Position.x) + 4 - 1 > Width - 1
                {
                    print("Bad position for horizontal 4 pattern")
                    return
                }
                for X in Int(Position.x) ..< Int(Position.x) + 4
                {
                    SetPiece(X, Int(Position.y), NewPiece: Piece)
                }
                
            case .Vertical4:
                if Int(Position.y) + 4 - 1 > Height - 1
                {
                    print("Bad position for vertical 3 pattern")
                    return
                }
                for Y in Int(Position.y) ..< Int(Position.y) + 4
                {
                    SetPiece(Int(Position.x), Y, NewPiece: Piece)
                }
                
            case .Horizontal5:
                if Int(Position.x) + 5 - 1 > Width - 1
                {
                    return
                }
                for X in Int(Position.x) ..< Int(Position.x) + 5
                {
                    SetPiece(X, Int(Position.y), NewPiece: Piece)
                }
                
            case .Vertical5:
                if Int(Position.y) + 5 - 1 > Height - 1
                {
                    print("Bad position for vertical 3 pattern")
                    return
                }
                for Y in Int(Position.y) ..< Int(Position.y) + 5
                {
                    SetPiece(Int(Position.x), Y, NewPiece: Piece)
                }
                
            default:
                break
        }
    }
}
