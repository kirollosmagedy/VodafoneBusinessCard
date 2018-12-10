//
//  ViewController.swift
//  VodafoneBusinessCard
//
//  Created by Kiro on 12/5/18.
//  Copyright © 2018 Kiro. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    
    //MARK:- Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    
    //MARK:- Variables
    var targetAnchor: ARImageAnchor?
    var businessCardPlaced = false
    var businessCardNode: BusinessCardNode!
    var menuShown = false

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        if let businessCardScene = SCNScene(named: "art.scnassets/card.scn")  {
            sceneView.scene = businessCardScene

        }
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "cards", bundle: Bundle.main)!
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        if !businessCardPlaced {
            businessCardNode = BusinessCardNode(for:node)
            businessCardPlaced = true
            node.addChildNode(businessCardNode)
            businessCardNode.animateBusinessCard()

        }
        targetAnchor = imageAnchor
        
        
    }
  
}

