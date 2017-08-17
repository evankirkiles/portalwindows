//
//  MainScene.swift
//  Portal Windows
//
//  Created by Sam Kirkiles on 8/5/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class MainScene {
    static let PLAYERBITMASK = 1
    static let WALLBITMASK = 2
    static let WINDOWBITMASK = 3
    
    class func createWindowedSkyBox(width: CGFloat, length: CGFloat, height: CGFloat) -> SCNNode {
        let completeSkyBox = SCNNode()
        
        let windowFrameScene = SCNScene(named: "art.scnassets/windowframe.dae")
        let windowFrame = windowFrameScene?.rootNode.childNode(withName: "windowFrame", recursively: true)
        windowFrame?.scale = SCNVector3(0.1, Float(Nodes.WINDOW_WIDTH) / (Float((windowFrame?.geometry?.boundingBox.max.z)!) - Float((windowFrame?.geometry?.boundingBox.min.z)!)),
                                        Float(Nodes.WINDOW_HEIGHT) / (Float((windowFrame?.geometry?.boundingBox.max.y)!) - Float((windowFrame?.geometry?.boundingBox.min.y)!)))
        windowFrame?.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(90.0))
        windowFrame?.position = SCNVector3(Float(Nodes.WINDOW_HEIGHT * 0.5),0,0)
        completeSkyBox.addChildNode(windowFrame!)
        
        let roofSegmentNode = Nodes.maskedPlaneNode(width: width, height: length)
        roofSegmentNode.name = ("roofSegmentNode")
        roofSegmentNode.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(90.0), 0)
        roofSegmentNode.position = SCNVector3(Float(height * -0.5), 0, 0)
        completeSkyBox.addChildNode(roofSegmentNode)
        
        let floorSegmentNode = Nodes.maskedPlaneNode(width: width, height: length)
        floorSegmentNode.name = ("floorSegmentNode")
        floorSegmentNode.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(270.0), 0)
        floorSegmentNode.position = SCNVector3(Float(height * 0.5), 0, Float(-length))
        completeSkyBox.addChildNode(floorSegmentNode)
        
        let endWallSegmentNode = Nodes.maskedPlaneNode(width: height, height: width)
        endWallSegmentNode.name = ("endWallSegmentNode")
        endWallSegmentNode.eulerAngles = SCNVector3(0, 0, 0)
        endWallSegmentNode.position = SCNVector3(Float(height * -0.5), 0, Float(-length))
        completeSkyBox.addChildNode(endWallSegmentNode)
        
        let rightWallSegmentNode = Nodes.maskedPlaneNode(width: height, height: length)
        rightWallSegmentNode.name = ("rightWallSegmentNode")
        rightWallSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(90.0), 0, 0)
        rightWallSegmentNode.position = SCNVector3(Float(height * -0.5), Float(width * 0.5), Float(length * -0.5))
        completeSkyBox.addChildNode(rightWallSegmentNode)
        
        let leftWallSegmentNode = Nodes.maskedPlaneNode(width: height, height: length)
        leftWallSegmentNode.name = ("leftWallSegmentNode")
        leftWallSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(270.0), 0, 0)
        leftWallSegmentNode.position = SCNVector3(Float(height * -0.5), Float(width * -0.5), Float(length * -0.5))
        completeSkyBox.addChildNode(leftWallSegmentNode)
        
        let leftDoorSideSegmentNode = Nodes.maskedPlaneNode(width: height, height: (width - Nodes.WINDOW_WIDTH)/2)
        leftDoorSideSegmentNode.name = ("leftDoorSideSegmentNode")
        leftDoorSideSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(180.0), 0, 0)
        leftDoorSideSegmentNode.position = SCNVector3(Float(height * -0.5), Float(width * -0.5 + (width - Nodes.WINDOW_WIDTH)/4), 0)
        completeSkyBox.addChildNode(leftDoorSideSegmentNode)
        
        let rightDoorSideSegmentNode = Nodes.maskedPlaneNode(width: height, height: (width - Nodes.WINDOW_WIDTH)/2)
        rightDoorSideSegmentNode.name = ("rightDoorSideSegmentNode")
        rightDoorSideSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToterRadians(180.0), 0, 0)
        rightDoorSideSegmentNode.position = SCNVector3(Float(height * -0.5), Float(width * 0.5 - (width - Nodes.WINDOW_WIDTH)/4), 0)
        completeSkyBox.addChildNode(rightDoorSideSegmentNode)
        
        let aboveDoorSideSegmentNode = Nodes.maskedPlaneNode(width: (height - Nodes.WINDOW_HEIGHT)/2, height: Nodes.WINDOW_WIDTH)
        aboveDoorSideSegmentNode.name = ("aboveDoorSideSegmentNode")
        aboveDoorSideSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(180.0), 0, 0)
        aboveDoorSideSegmentNode.position = SCNVector3(Float(height * -0.5), 0, 0)
        completeSkyBox.addChildNode(aboveDoorSideSegmentNode)
        
        let belowDoorSideSegmentNode = Nodes.maskedPlaneNode(width: (height - Nodes.WINDOW_HEIGHT)/2, height: Nodes.WINDOW_WIDTH)
        belowDoorSideSegmentNode.name = ("belowDoorSideSegmentNode")
        belowDoorSideSegmentNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(180.0), 0, 0)
        belowDoorSideSegmentNode.position = SCNVector3(Float(height * 0.5 - (height - Nodes.WINDOW_HEIGHT)/2), 0, 0)
        completeSkyBox.addChildNode(belowDoorSideSegmentNode)
        
        let placeholderSphereNode = SCNNode(geometry: SCNSphere(radius: 0.2))
        placeholderSphereNode.position = SCNVector3(0, 0, -1)
        placeholderSphereNode.renderingOrder = 200
        completeSkyBox.addChildNode(placeholderSphereNode)
        
        return completeSkyBox
    }
    
    // TODO: Check it in the REAL coordinate system not the parent system
    class func checkIfWithinSkyBox(location: SCNVector3, skybox: SCNNode) -> Bool {
        if (location.y < (skybox.childNode(withName: "leftWallSegmentNode", recursively: true)?.worldPosition.y)! && location.y > (skybox.childNode(withName: "rightWallSegmentNode", recursively: true)?.worldPosition.y)!) ||
            (location.y > (skybox.childNode(withName: "leftWallSegmentNode", recursively: true)?.worldPosition.y)! && location.y < (skybox.childNode(withName: "rightWallSegmentNode", recursively: true)?.worldPosition.y)!) {
            print("y test passed")
            if (location.x < (skybox.childNode(withName: "floorSegmentNode", recursively: true)?.worldPosition.x)! && location.x > (skybox.childNode(withName: "roofSegmentNode", recursively: true)?.worldPosition.x)!) ||
                (location.x > (skybox.childNode(withName: "floorSegmentNode", recursively: true)?.worldPosition.x)! && location.x < (skybox.childNode(withName: "roofSegmentNode", recursively: true)?.worldPosition.x)!) {
                print("x test passed")
                if (location.z < (skybox.childNode(withName: "aboveDoorSideSegmentNode", recursively: true)?.worldPosition.z)! && location.x > (skybox.childNode(withName: "endWallSegmentNode", recursively: true)?.worldPosition.z)!) ||
                    (location.z > (skybox.childNode(withName: "aboveDoorSideSegmentNode", recursively: true)?.worldPosition.z)! && location.x < (skybox.childNode(withName: "endWallSegmentNode", recursively: true)?.worldPosition.z)!) {
                    return true
                } else { return false }
            } else { return false }
        } else { return false }
    }
}
