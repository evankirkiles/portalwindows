//
//  Nodes.swift
//  Portal Windows
//
//  Created by Sam Kirkiles on 8/4/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import Foundation
import SceneKit

class Nodes {
    static let WINDOW_HEIGHT: CGFloat = 0.4
    static let WINDOW_WIDTH: CGFloat = 0.2
    
    static let PLAYER_HEIGHT: CGFloat = 0.01
    static let PLAYER_WIDTH: CGFloat = 0.01
    static let PLAYER_LENGTH: CGFloat = 0.01
    
    class func initializePlayerNode() -> SCNNode {
        let playerBox = SCNBox(width: Nodes.PLAYER_WIDTH, height: Nodes.PLAYER_HEIGHT, length: Nodes.PLAYER_LENGTH, chamferRadius: 0)
        let playerNode = SCNNode(geometry: playerBox)
        playerNode.name = "playerNode"
        playerNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: playerBox))
        playerNode.physicsBody?.isAffectedByGravity = false
        playerNode.physicsBody!.categoryBitMask = MainScene.PLAYERBITMASK
        playerNode.physicsBody!.collisionBitMask = 0
        playerNode.physicsBody!.contactTestBitMask = MainScene.WALLBITMASK
        
        return playerNode
    }
    
    class func maskedPlaneNode(width: CGFloat, height: CGFloat, texture: UIImage? = nil) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        if texture != nil {
            plane.firstMaterial?.diffuse.contents = texture
        } else {
            plane.firstMaterial?.diffuse.contents = UIColor.clear
        }
        plane.firstMaterial?.isDoubleSided = false
        let planeNode = SCNNode(geometry: plane)
        planeNode.renderingOrder = 200
        planeNode.position = SCNVector3(width * 0.5, 0, 0)
        
        let maskingPlane = SCNPlane(width: width, height: height)
        maskingPlane.firstMaterial?.diffuse.contents = UIColor.red
        maskingPlane.firstMaterial?.transparency = 0.000001
        maskingPlane.firstMaterial?.isDoubleSided = false
        let maskingPlaneNode = SCNNode(geometry: maskingPlane)
        maskingPlaneNode.renderingOrder = 100
        maskingPlaneNode.position = SCNVector3(width * 0.5, 0, 0)
        maskingPlaneNode.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(180.0), 0)
        maskingPlaneNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: maskingPlane))
        maskingPlaneNode.physicsBody?.isAffectedByGravity = false
        maskingPlaneNode.physicsBody!.categoryBitMask = MainScene.WALLBITMASK
        maskingPlaneNode.physicsBody!.collisionBitMask = 0
        maskingPlaneNode.physicsBody!.contactTestBitMask = MainScene.PLAYERBITMASK
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        node.addChildNode(maskingPlaneNode)
        
        return node
    }
}
