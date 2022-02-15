//
//  +GameViewControllerButtonHandling.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/16/22.
//

import Foundation
import UIKit
import SceneKit

extension GameViewController
{
    // MARK: - Handling for UI buttons.
    
    func AddButtons()
    {
        let Top = UIScreen.main.bounds.origin.y
        let Bottom = UIScreen.main.bounds.origin.y +
        UIScreen.main.bounds.size.height
        
        MatchButton = UIButton(frame: CGRect(x: 20, y: Top + 50,
                                             width: 70, height: 20))
        MatchButton?.addTarget(self, action: #selector(HandleMatchButtonPress),
                               for: .touchUpInside)
        MatchButton?.setTitle("Match", for: .normal)
        MatchButton?.backgroundColor = UIColor.white
        MatchButton?.setTitleColor(UIColor.black, for: .normal)
        MatchButton!.layer.zPosition = 500
        self.view.addSubview(MatchButton!)
        
        RandomFlyButton = UIButton(frame: CGRect(x: 150, y: Top + 50,
                                                 width: 100, height: 20))
        RandomFlyButton?.addTarget(self, action: #selector(HandleRandomFlying),
                                   for: .touchUpInside)
        RandomFlyButton?.setTitle("Random Fly", for: .normal)
        RandomFlyButton?.backgroundColor = UIColor.white
        RandomFlyButton?.setTitleColor(UIColor.black, for: .normal)
        RandomFlyButton!.layer.zPosition = 500
        self.view?.addSubview(RandomFlyButton!)
        
#if targetEnvironment(macCatalyst)
        let DropY = 90.0
#else
        let DropY = 80.0
#endif
        DropButton = UIButton(frame: CGRect(x: 20, y: Top + DropY,
                                            width: 50, height: 20))
        DropButton?.addTarget(self, action: #selector(HandleDropButtonPress),
                              for: .touchUpInside)
        DropButton?.setTitle("Drop", for: .normal)
        DropButton?.backgroundColor = UIColor.white
        DropButton?.setTitleColor(UIColor.black, for: .normal)
        DropButton!.layer.zPosition = 500
        self.view.addSubview(DropButton!)
        
        LockButton = UIButton(frame: CGRect(x: 150, y: Top + DropY,
                                            width: 80, height: 20))
        LockButton?.addTarget(self, action: #selector(HandleLockButtonPress),
                              for: .touchUpInside)
        LockButton?.setTitle("Lock", for: .normal)
        LockButton?.backgroundColor = UIColor.white
        LockButton?.setTitleColor(UIColor.black, for: .normal)
        LockButton!.layer.zPosition = 500
        self.view.addSubview(LockButton!)
        
#if targetEnvironment(macCatalyst)
        let ResetY = 130.0
#else
        let ResetY = 110.0
#endif
        ResetButton = UIButton(frame: CGRect(x: 20, y: Top + ResetY,
                                             width: 80, height: 20))
        ResetButton?.addTarget(self, action: #selector(HandleResetButtonPress),
                               for: .touchUpInside)
        ResetButton?.setTitle("Reset", for: .normal)
        ResetButton?.backgroundColor = UIColor.white
        ResetButton?.setTitleColor(UIColor.black, for: .normal)
        ResetButton!.layer.zPosition = 500
        self.view.addSubview(ResetButton!)
        
        URotateButton = UIButton(frame: CGRect(x: 20, y: Top + ResetY,
                                               width: 80, height: 20))
        URotateButton?.addTarget(self, action: #selector(HandleURotate),
                                 for: .touchUpInside)
        URotateButton?.setTitle("U Rotate", for: .normal)
        URotateButton?.backgroundColor = UIColor.white
        URotateButton?.setTitleColor(UIColor.black, for: .normal)
        URotateButton!.layer.zPosition = 500
        self.view.addSubview(URotateButton!)
        
        RotateButton = UIButton(frame: CGRect(x: 150, y: Top + ResetY,
                                width: 80.0, height: 20.0))
        RotateButton?.addTarget(self, action: #selector(HandleRotateButtonPress),
                                for: .touchUpInside)
        RotateButton?.setTitle("Rotate", for: .normal)
        RotateButton?.backgroundColor = UIColor.white
        RotateButton?.setTitleColor(UIColor.black, for: .normal)
        RotateButton!.layer.zPosition = 500
        self.view.addSubview(RotateButton!)
    }
    
    #if DEBUG
    @objc func HandleURotate()
    {
        RunningURotate = !RunningURotate
        if RunningURotate
        {
            HandleURotation()
            URotateTimer = Timer.scheduledTimer(timeInterval: 0.8,
                                                target: self,
                                                selector: #selector(HandleURotation),
                                                userInfo: nil,
                                                repeats: true)
        }
        else
        {
            URotateTimer?.invalidate()
            URotateTimer = nil
        }
    }
    
    @objc func HandleURotation()
    {
        #if true
        var XAngle = [-90.0, 0.0, 90.0].randomElement()!.Radians
        var YAngle = [-90.0, 0.0, 90.0].randomElement()!.Radians
        if XAngle == 0.0 && YAngle == 0.0
        {
            XAngle = [-90.0, 90.0].randomElement()!.Radians
        }
        let Rotate = SCNAction.rotateBy(x: YAngle, y: XAngle, z: 0.0,
                                        duration: 0.65)
        self.PlaySurface?.Surface.runAction(Rotate)
        #else
        if Bool.random()
        {
            let XMultiplier = Bool.random() ? 1.0 : -1.0
            self.URotateX = self.URotateX + (XMultiplier * 90.0)
            self.URotateX = fmod(self.URotateX, 360.0)
            print("URotateX = \(URotateX)")
            let Rotate = SCNAction.rotateBy(x: 0.0, y: self.URotateX.Radians, z: 0.0,
                                            duration: 1.0)
            self.PlaySurface?.Surface.runAction(Rotate)
        }
        else
        {
        let YMultiplier = Bool.random() ? 1.0 : -1.0
        self.URotateY = self.URotateY + (YMultiplier * 90.0)
        self.URotateY = fmod(self.URotateY, 360.0)
            print("URotateY = \(URotateY)")
            let Rotate = SCNAction.rotateBy(x: self.URotateY.Radians, y: 0.0, z: 0.0,
                                        duration: 1.0)
        self.PlaySurface?.Surface.runAction(Rotate)
        }
        #endif
    }
    
    @objc func HandleRotateButtonPress()
    {
        DebugRotating = !DebugRotating
        if DebugRotating
        {
            var RotateXBy = CGFloat.random(in: 0.0 ... 360.0).Radians
            var RotateYBy = CGFloat.random(in: 0.0 ... 360.0).Radians
            var RotateZBy = CGFloat.random(in: 0.0 ... 360.0).Radians
            if Bool.random()
            {
                RotateXBy = RotateXBy * -1.0
            }
            if Bool.random()
            {
                RotateYBy = RotateYBy * -1.0
            }
            RotateYBy = -abs(RotateYBy)
            if Bool.random()
            {
                RotateZBy = RotateZBy * -1.0
            }
            let XDuration = Double.random(in: 0.75 ... 2.0)
            let YDuration = Double.random(in: 0.75 ... 2.0)
            let ZDuration = Double.random(in: 0.75 ... 2.0)
            //let RotateX = SCNAction.rotateBy(x: RotateXBy, y: 0.0, z: 0.0, duration: XDuration)
            let RotateY = SCNAction.rotateBy(x: 0.0, y: RotateYBy, z: 0.0, duration: YDuration)
            //let RotateZ = SCNAction.rotateBy(x: 0.0, y: 0.0, z: RotateZBy, duration: ZDuration)
            //let Group = SCNAction.group([RotateX, RotateY, RotateZ])
            let Group = SCNAction.group([RotateY])
            let Forever = SCNAction.repeatForever(Group)
            PlaySurface?.Surface.runAction(Forever, forKey: "TestRotation")
        }
        else
            {
                PlaySurface?.Surface.removeAction(forKey: "TestRotation")
            }
    }
    
    @objc func HandleMatchButtonPress()
    {
        var TotalToRemove = 0
        guard let Working = PlaySurface?.GetBoard(On: .A) else
        {
            Debug.FatalError("Error getting board .A")
        }
        MatchCheck.CheckForMatches2(On: Working)
        {
            RemoveList in
            Working.RemoveNodes(RemoveList)
        }
    }
    
    @objc func HandleRandomFlying()
    {
        if RandomFlying
        {
            print("Turned off random flying")
            LastTestSide = nil
            LastTestX = nil
            LastTestY = nil
            RandomFlying = false
            RandomFlyTimer?.invalidate()
        }
        else
        {
            print("Testing random flying")
            RandomFlying = true
            RandomFlyTimer = Timer(timeInterval: 0.5,
                                   target: self,
                                   selector: #selector(TestRandomFlying),
                                   userInfo: nil,
                                   repeats: true)
            RunLoop.main.add(RandomFlyTimer!, forMode: .common)
            TestRandomFlying()
        }
    }
    
    @objc func TestRandomFlying()
    {
        var Side: BoardPlanes = .A
        var X: Int = 0
        var Y: Int = 0
        while true
        {
            Side = BoardPlanes.allCases.randomElement()!
            X = Int.random(in: 0 ... 9)
            Y = Int.random(in: 0 ... 9)
            if LastTestSide == nil && LastTestX == nil && LastTestY == nil
            {
                LastTestSide = Side
                LastTestX = X
                LastTestY = Y
                break
            }
            if LastTestSide! != Side && LastTestX! != X && LastTestY! != Y
            {
                break
            }
        }
        if let Surface = PlaySurface?.Surface
        {
            SideManager.PieceFly(Side, X, Y, BoardSize: CGSize(width: 8.0, height: 8.0),
                                 Extent: 9, FlyDuration: 2.0, true, 0.35, Surface)
        }
    }
    
    @objc func HandleDropButtonPress()
    {
        PlaySurface?.GetBoard(On: .A).DropPieces()
    }
    
    @objc func HandleResetButtonPress()
    {
        PlaySurface?.ResetAllBoards(Extent: 9, MaxPiece: 4)
    }
    
    @objc func HandleLockButtonPress()
    {
        IsRotationLocked = !IsRotationLocked
        if IsRotationLocked
        {
            LockButton?.setTitle("Unlock", for: .normal)
            GameView.allowsCameraControl = false
        }
        else
        {
            LockButton?.setTitle("Lock", for: .normal)
            GameView.allowsCameraControl = true
        }
    }
    #endif
}
