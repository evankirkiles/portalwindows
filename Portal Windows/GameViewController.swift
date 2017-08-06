//
//  ViewController.swift
//  Portal Windows
//
//  Created by Sam Kirkiles on 8/1/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, ARSessionDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    var windowAnchor: ARAnchor?
    var playerAnchor: ARAnchor?
    var playerNode: SCNNode?
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    override var shouldAutorotate: Bool { return false }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.session.delegate = self as ARSessionDelegate
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create the player node
        playerNode = Nodes.initializePlayerNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            playerAnchor = ARAnchor(transform: (sceneView.session.currentFrame?.camera.transform)!)
            sceneView.session.add(anchor: playerAnchor!)
            windowAnchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: windowAnchor!)
        }
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor == playerAnchor {
            playerNode?.position = SCNVector3Make(playerAnchor!.transform.columns.3.x, playerAnchor!.transform.columns.3.y, playerAnchor!.transform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(playerNode!)
            return playerNode
        } else if anchor == windowAnchor {
            let skyBox = MainScene.createWindowedSkyBox(width: 2, length: 2, height: 2)
            skyBox.position = SCNVector3Make(windowAnchor!.transform.columns.3.x, 0, windowAnchor!.transform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(skyBox)
            return skyBox
        } else {
            return nil
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact made")
        if contact.nodeB.physicsBody!.categoryBitMask == MainScene.WALLBITMASK || contact.nodeA.physicsBody!.categoryBitMask == MainScene.WALLBITMASK {
            print("ran into a wall idiot")
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTransform = frame.camera.transform
        playerAnchor = ARAnchor(transform: currentTransform)
        playerNode?.position = SCNVector3Make(playerAnchor!.transform.columns.3.x, playerAnchor!.transform.columns.3.y, playerAnchor!.transform.columns.3.z)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
