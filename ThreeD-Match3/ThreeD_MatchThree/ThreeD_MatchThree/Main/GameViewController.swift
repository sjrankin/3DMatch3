//
//  GameViewController.swift
//  ThreeD_MatchThree
//
//  Created by Stuart Rankin on 1/8/22.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
#if targetEnvironment(macCatalyst)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
#else
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 19)
#endif
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        let Light = SCNLight()
        Light.color = UIColor.white
        lightNode.light = Light
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        lightNode.castsShadow = true
        lightNode.categoryBitMask = 0x10
        //        lightNode.light?.shadowMode = .forward
        //        lightNode.light?.shadowRadius = 5.0
        //        lightNode.light?.shadowColor = UIColor.black
        /*
         Light.shadowSampleCount = 16
         Light.shadowMapSize = CGSize(width: 2048, height: 2048)
         Light.automaticallyAdjustsShadowProjection = true
         Light.shadowCascadeCount = 3
         Light.shadowCascadeSplittingFactor = 0.09
         Light.shadowColor = UIColor.black.withAlphaComponent(0.80)
         Light.shadowRadius = 5.0
         */
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add gesture recognizers
        
        let DoubleTap = UITapGestureRecognizer(target: self, action: #selector(HandleDoubleTap(_:)))
        DoubleTap.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(DoubleTap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HandleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let Panning = UIPanGestureRecognizer(target: self, action: #selector(HandlePan(_:)))
        scnView.addGestureRecognizer(Panning)
        
        scnView.antialiasingMode = .multisampling4X
        
#if true
        PlaySurface = GameSurface(scnView, Extent: 9,
                                  Width: 8.0, Height: 8.0)
        InitializeSideManager()
#else
        let BoardExtent = 9
        
        PlaySurface = GameSurface(scnView, Extent: BoardExtent,
                                  Width: 8.0, Height: 8.0)
        PlaySurface?.ResetAllBoards(Extent: 9, MaxPiece: 4)
#endif
        
        AddButtons()
    }
    
    func InitializeSideManager()
    {
        SideManager.CreateManagedSides(Parent: PlaySurface!.Surface,
                                       HorizontalExtent: 9,
                                       VerticalExtent: 9,
                                       HorizontalSize: 8.0,
                                       VerticalSize: 8.0)
    }
    
    var PlaySurface: GameSurface? = nil
    var SurfaceMap = [BoardPlanes: Board]()
    
    var MatchButton: UIButton? = nil
    var DropButton: UIButton? = nil
    var LockButton: UIButton? = nil
    var RotateButton: UIButton? = nil
    var URotateButton: UIButton? = nil
    var URotateTimer: Timer? = nil
    var RunningURotate = false
    var URotateX = 0.0
    var URotateY = 0.0
    var ResetButton: UIButton? = nil
    var RandomFlyButton: UIButton? = nil
    var DebugRotating: Bool = false
    var LastTestSide: BoardPlanes? = nil
    var LastTestX: Int? = nil
    var LastTestY: Int? = nil
    var RandomFlyTimer: Timer? = nil
    var RandomFlying: Bool = false
    var IsRotationLocked = false
    var InitialPanningLocation: CGPoint? = nil
    var CurrentlyPanning: Bool = false
    
    @objc func HandlePan(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        let scnView = self.view as! SCNView
        let Point = gestureRecognizer.location(in: scnView)
        let HitResults = scnView.hitTest(Point, options: [:])
        if HitResults.count > 0 && !CurrentlyPanning
        {
            //No panning gestures if start on a game object. But, panning will
            //be executed if the user drags over a game object if the pan gesture
            //starts outside of all game objects.
            return
        }
        
        let ViewWidth = scnView.frame.size.width
        let ViewHeight = scnView.frame.size.height
        
        switch gestureRecognizer.state
        {
            case .began:
                InitialPanningLocation = Point
                CurrentlyPanning = true
                print("Started panning from \(Point)")
                let Starting = PlaySurface!.Surface.eulerAngles
                print("  Staring euler angles: \(Starting.DegreeString())")
                
            case .cancelled,
                    .ended:
                if !CurrentlyPanning
                {
                    guard let StartPoint = InitialPanningLocation else
                    {
                        return
                    }
                    //We have the starting and ending point for moving a game piece.
                    let EndingPoint = Point
                    print("StartPoint=\(StartPoint), EndPoint=\(EndingPoint)")
                }
                CurrentlyPanning = false
                InitialPanningLocation = nil
                PreviousPoint = nil
                
            default:
                //do most stuff here
                guard let StartPoint = InitialPanningLocation else
                {
                    //If we are here, the user is moving a game piece.
                    return
                }
                
                let Ending = PlaySurface!.Surface.eulerAngles
                print("  Ending euler angles: \(Ending.DegreeString())")
                
                let Translation = gestureRecognizer.translation(in: scnView)
                let NewPoint = CGPoint(x: Translation.x + StartPoint.x,
                                       y: Translation.y + StartPoint.y)
                var NewX: CGFloat = 0.0
                var NewY: CGFloat = 0.0
                if PreviousPoint == nil
                {
                    PreviousPoint = NewPoint
                }
                else
                {
                    NewX = NewPoint.x - PreviousPoint!.x
                    if abs(NewX) < 1.0
                    {
                        NewX = 0.0
                    }
                    NewY = NewPoint.y - PreviousPoint!.y
                    if abs(NewY) < 1.0
                    {
                        NewY = 0.0
                    }
                    PreviousPoint = NewPoint
                }
                let XPercent = NewX / ViewWidth
                let YPercent = NewY / ViewHeight
                let XDegrees = 180.0 * XPercent
                let YDegrees = 180.0 * YPercent
                let XRadians = XDegrees.Radians
                let YRadians = YDegrees.Radians
                let XRotate = SCNAction.rotateBy(x: YRadians, y: XRadians, z: 0.0, duration: 0.01)
                PlaySurface?.Surface.runAction(XRotate)
        }
    }
    
    var PreviousPoint: CGPoint? = nil
    var PreviousWidthPercent: Double? = nil
    var PreviousHeightPercent: Double? = nil
    var PreviousHorizontal: Float? = nil
    var PreviousVertical: Float? = nil
    var HorizontalDirection: Double = 0.0
    var LastHorizontalValue: CGFloat? = nil
    var VerticalDirection: Double = 0.0
    var LastVerticalValue: CGFloat? = nil
    var FirstObjectTapped: SCNNodeEx? = nil
    var SecondObjectTapped: SCNNodeEx? = nil
    
    @objc func HandleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        print("At double tap handler")
        //guard let LastSide = LastTappedSide else
        //{
        //    return
        //}
        
        if let Surface = PlaySurface?.Surface
        {
            let Orientation = Surface.eulerAngles
            let X = Orientation.x.Degrees
            let Y = Orientation.y.Degrees
            let Z = Orientation.z.Degrees
//            print("Game surface euler angle = (\(X)°,\(Y)°,\(Z)°)")
            print("Game surface euler angle = \(Orientation.DegreeString())")
            let XMod = fmod(X, 90.0)
            let YMod = fmod(Y, 90.0)
            print("XMod=\(XMod)")
            print("YMod=\(YMod)")
            let ResetOrientation = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0,
                                                      duration: 0.5,
                                                      usesShortestUnitArc: true)
            Surface.runAction(ResetOrientation)
            {
                let NewOri = Surface.eulerAngles
                print("New game surface euler angle = \(NewOri.DegreeString())")
                /*
                let X = NewOri.x.Degrees
                let Y = NewOri.y.Degrees
                let Z = NewOri.z.Degrees
                print("New game surface euler angle = (\(X)°,\(Y)°,\(Z)°)")
                 */
            }
        }
    }
    
    var LastTappedSide: BoardPlanes? = nil
    
    @objc func HandleTap(_ gestureRecognizer: UIGestureRecognizer)
    {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0
        {
            if FirstObjectTapped == nil
            {
                guard let FirstTapped = hitResults[0].node as? SCNNodeEx else
                {
                    print("First tapped object not SCNNodeEx")
                    return
                }
                    FirstObjectTapped = FirstTapped
                print("FirstTapped=\(FirstTapped.Plane): \(FirstTapped.LogicalX),\(FirstTapped.LogicalY)")
                SecondObjectTapped = nil
            } else if FirstObjectTapped != nil && SecondObjectTapped == nil
            {
                guard let SecondTapped = hitResults[0].node as? SCNNodeEx else
                {
                    print("Second tapped object not SCNNodeEx")
                    return
                }
                SecondObjectTapped = SecondTapped
                print("SecondTapped=\(SecondTapped.Plane): \(SecondTapped.LogicalX),\(SecondTapped.LogicalY)")
                if FirstObjectTapped!.NodeID == SecondObjectTapped!.NodeID
                {
                    print("First node is same as second node")
                    FirstObjectTapped = nil
                    SecondObjectTapped = nil
                }
            }
            if FirstObjectTapped != nil && SecondObjectTapped != nil
            {
                if !SideManager.ValidSwap(FirstObjectTapped!, SecondObjectTapped!)
                {
                    print("Nodes are not adjacent.")
                    FirstObjectTapped = nil
                    SecondObjectTapped = nil
                    return
                }
                LastTappedSide = SecondObjectTapped?.Plane
                let FirstX = FirstObjectTapped!.LogicalX
                let FirstY = FirstObjectTapped!.LogicalY
                let FirstSide = FirstObjectTapped!.Plane
                let SecondX = SecondObjectTapped!.LogicalX
                let SecondY = SecondObjectTapped!.LogicalY
                let SecondSide = SecondObjectTapped!.Plane
                let FirstPoint = CGPoint(x: CGFloat(FirstObjectTapped!.position.x),
                                         y: CGFloat(FirstObjectTapped!.position.y))
                let SecondPoint = CGPoint(x: CGFloat(SecondObjectTapped!.position.x),
                                          y: CGFloat(SecondObjectTapped!.position.y))
                let (Mid, DeltaX, DeltaY) = CGPoint.MidPoint(FirstPoint, SecondPoint)
                let Angle = CGPoint.AngleBetween(FirstPoint, And: SecondPoint)
                SideManager.Swap(FirstObjectTapped!.NodeID, SecondObjectTapped!.NodeID,
                                 BoardSize: CGSize(width: 8.0, height: 8.0),
                                 BoardExtent: 9, Surface: PlaySurface!.Surface)
                let IsHorizontal = FirstObjectTapped!.position.y == SecondObjectTapped!.position.y
                let FinalRadius = (IsHorizontal ? DeltaX : DeltaY) / 2.0
                AddTestCircle(At: SCNVector3(x: Float(Mid.x), y: Float(Mid.y), z: 4.0),
                              Radius: Double(FinalRadius), Angle: Angle, DeltaX, DeltaY,
                              Horizontal: IsHorizontal)
                FirstObjectTapped = nil
                SecondObjectTapped = nil
            }
            // retrieved the first clicked object
            let result = hitResults[0]
            
            if let PieceNode = result.node as? SCNNodeEx
            {
                print("Piece location: \(PieceNode.Plane.rawValue):(\(PieceNode.LogicalX),\(PieceNode.LogicalY))")
            }
            
            scnView.backgroundColor = UIColor.black
            //scnView.allowsCameraControl = false
            
            // get its material
            let material = result.node.geometry!.materials[result.geometryIndex]
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock =
            {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
        else
        {
            #if true
            scnView.backgroundColor = UIColor.Random()
            //scnView.allowsCameraControl = true
            #else
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.completionBlock =
            {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                scnView.backgroundColor = UIColor.black
                SCNTransaction.commit()
            }
            scnView.backgroundColor = UIColor.red
            SCNTransaction.commit()
            #endif
        }
    }
    
    func AddTestCircle(At: SCNVector3, Radius: Double, Angle: Double, _ DeltaX: CGFloat,
                       _ DeltaY: CGFloat, Horizontal: Bool)
    {
        let Cylinder = SCNCylinder(radius: Radius, height: 0.02)
        let DebugNode = SCNNode(geometry: Cylinder)
        DebugNode.geometry?.firstMaterial?.diffuse.contents = Horizontal ? UIColor.ArtichokeGreen : UIColor.OrangePeel
        DebugNode.position = SCNVector3(x: At.x,
                                        y: At.y,
                                        z: At.z)
        PlaySurface?.Surface.addChildNode(DebugNode)
        if !Horizontal
        {
            let RotateMe = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 90.0.Radians,
                                            duration: 1.0)
            DebugNode.runAction(RotateMe)
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    @IBOutlet var GameView: SCNView!
}
