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
    
    var wallHits: Int = 0
    
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
        
        // Initialize player
        playerNode = Nodes.initializePlayerNode()
        sceneView.scene.rootNode.addChildNode(playerNode!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            playerAnchor = ARAnchor(transform: currentFrame.camera.transform)
            sceneView.session.add(anchor: playerAnchor!)
            windowAnchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: windowAnchor!)
        }
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor == windowAnchor {
            let skyBox = MainScene.createWindowedSkyBox(width: 2, length: 2, height: 2)
            skyBox.position = SCNVector3Make(windowAnchor!.transform.columns.3.x, 0, windowAnchor!.transform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(skyBox)
            return skyBox
        } else {
            return nil
        }
    }
    
    // Called when the player collides with a masking wall
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contact.nodeB.physicsBody!.categoryBitMask == MainScene.WALLBITMASK {
            print(contact.nodeA.name, contact.nodeB.parent!.name)
            if MainScene.checkIfWithinSkyBox(location: contact.nodeA.position, skybox: contact.nodeB.parent!.parent!) {
                // Hide the scene
                wallHits += 1
                print("scene being hidden" + String(wallHits))
            } else {
                print("not in skybox")
            }
        } else if contact.nodeB.physicsBody!.categoryBitMask == MainScene.WINDOWBITMASK {
            // Create the other half of the scene
        }
    }
    
    // Called every frame, currently used to update player location
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        playerNode?.position = SCNVector3Make(frame.camera.transform.columns.3.x, frame.camera.transform.columns.3.y, frame.camera.transform.columns.3.z-0.0000001)
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
