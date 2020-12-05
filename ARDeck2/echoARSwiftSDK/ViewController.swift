//
//  ViewController.swift
//  EchoAR-iOS-SceneKit
//
//  Copyright © echoAR, Inc. 2018-2020.
//
//  Use subject to the Terms of Service available at https://www.echoar.xyz/terms,
//  or another agreement between echoAR, Inc. and you, your company or other organization.
//
//  Unless expressly provided otherwise, the software provided under these Terms of Service
//  is made available strictly on an “AS IS” BASIS WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
//  Please review the Terms of Service for details on these and other terms and conditions.
//
//  Created by Alexander Kutner.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes: [SCNNode] = []
    var echoImgEntryId = "88e5aa30-395f-4572-9beb-4427e915260c"
    var e:EchoAR!;
    var isSceneRendered = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        e = EchoAR();
        let scene = SCNScene()
        /*
        e.loadAllNodes(){ (nodes) in
            for node in nodes{
                node.position = SCNVector3(0, 0, 0)
                scene.rootNode.addChildNode(node);
            }
        }
        */

        e.loadSceneFromEntryID(entryID: echoImgEntryId, completion: { (scene) in
            guard let selectedNode = scene.rootNode.childNodes.first else {return}
            
        })
        
        // Set the scene to the view
        sceneView.scene=scene;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.75)

        let planeNode = SCNNode(geometry: plane)

        planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.x, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2

        node.addChildNode(planeNode)
      
        //save plane (so it can be edited later)
        planes.append(planeNode)
            
        let w = CGFloat(planeAnchor.extent.x)
        let h = CGFloat(planeAnchor.extent.z)
        let planeB = SCNPlane(width: w, height: h)
        let planeNodeB = SCNNode(geometry: planeB)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNodeB.position = SCNVector3(x,y,z)
        planeNodeB.eulerAngles.x = 0

            
        if !isSceneRendered {
            isSceneRendered = true
            e.loadSceneFromEntryID(entryID: echoImgEntryId, completion: { (scene) in
                guard let selectedNode = scene.rootNode.childNodes.first else {return}
                selectedNode.scale = SCNVector3(0.01, 0.01, 0.01)
                selectedNode.position = SCNVector3(x,y,z)
                selectedNode.eulerAngles = planeNodeB.eulerAngles
                self.sceneView.scene.rootNode.addChildNode(selectedNode)
                })
            }
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane {
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        }
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
