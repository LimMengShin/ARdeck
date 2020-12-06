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
    var sceneNode = SCNNode()
    var sceneRendered = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        // Create a new scene
        let scene = SCNScene()
        let e = EchoAR();
        //let scene = SCNScene()
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
        sceneView.scene = scene

        self.loadScene()
        sceneView.scene=scene;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        // load the scene
        sceneView.session.run(configuration)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    private func loadScene() {
        e.loadSceneFromEntryID(entryID: echoImgEntryId, completion: { (scene) in
            guard let scene = scene else {
                return
            }
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

            let childNodes = scene.rootNode.childNodes
            for childNode in childNodes {
                sceneNode.addChildNode(childNode)
            }
        })
    }

    private func addScene(position: SCNVector3) {
        sceneNode.scale = SCNVector3(0.02, 0.02, 0.02)
        sceneNode.position = position
        // Create a custom object to visualize the plane geometry and extent.
        let w = CGFloat(planeAnchor.extent.x)
        let h = CGFloat(planeAnchor.extent.z)

        sceneView.scene.rootNode.addChildNode(sceneNode)
    }

    private func addScene(transform: SCNMatrix4) {
        sceneNode.scale = SCNVector3(0.02, 0.02, 0.02)
        sceneNode.transform = transform
        sceneView.scene.rootNode.addChildNode(sceneNode)
    }
        //create a new plane
        let plane = SCNPlane(width: w, height: h)

        //set the color of the plane
        //plane.materials.first?.diffuse.contents = planeColor!
        //create a plane node from the scene plane
        let planeNode = SCNNode(geometry: plane)

        //get the x, y, and z locations of the plane anchor
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)

        //set the plane position to the x,y,z postion
        planeNode.position = SCNVector3(x,y,z)

        //turn th plane node so it lies flat vertically, rather than stands up vertically
        planeNode.eulerAngles.x = -.pi / 2

        //set the name of the plane
        planeNode.name = "plane"

        //add plane to scene
        node.addChildNode(planeNode)



        //save plane (so it can be edited later)
        planes.append(planeNode)

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.5)
            //plane.firstMaterial?.specular.contents = UIColor.white
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
    }

            if !sceneRendered {
                sceneRendered = true

                //let mainSceneClone = sceneNode.clone()
                sceneNode.scale = SCNVector3(0.01, 0.01, 0.01)
                sceneNode.position = SCNVector3Zero
                node.addChildNode(sceneNode)
            }

            /*
            if !wasAdded {
                wasAdded = true
                //mainSceneNode.position = planeNode.position
                let parentNode = SCNNode()
                
                let geometry = SCNSphere(radius: 0.05)
                let sceneNode = SCNNode(geometry: geometry)
                
                parentNode.addChildNode(sceneNode)
                //sceneNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
                sceneNode.transform = parentNode.convertTransform(planeNode.transform, from: planeNode.parent)
                
                sceneView.scene.rootNode.addChildNode(parentNode)
//                mainSceneNode.scale = SCNVector3(0.02, 0.02, 0.02)
//                mainSceneNode.eulerAngles.x = .pi / 2
//                planeNode.addChildNode(mainSceneNode)
                //sceneNode.position = node.convertPosition(planeNode.position, to: nil)
                //sceneView.scene.rootNode.addChildNode(mainSceneNode)
//                DispatchQueue.main.async {
//                    let transform = node.worldTransform
//                    self.addScene(transform: transform)
//                    let position = planeNode.worldPosition
//                    self.addScene(position: position)
//                }
            }
 */
        }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    /*
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane {
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
            
            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
 
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            node.childNodes.forEach({ (childNode) in
                childNode.removeFromParentNode()
            })
        }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
 */
}
