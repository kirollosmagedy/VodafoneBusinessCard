//
//  BusinessCardNode.swift
//  VodafoneBusinessCard
//
//  Created by Kiro on 12/5/18.
//  Copyright © 2018 Kiro. All rights reserved.
//

import Foundation
import ARKit
import WebKit

class BusinessCardNode:SCNNode {
    
    let Flipped_Rotation = SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(360))
    var interactiveButtons = [SCNNode]()
    var businessCard =  BusinessCard()

    var cardRoot:SCNNode! { didSet { facebookNode.name = "facebook" } }

    var facebookNode:SCNNode! { didSet { facebookNode.name = "facebook" } }
    var phoneNode:SCNNode! { didSet { phoneNode.name = "phone" } }
    var vodafoneTextNode:SCNText! { didSet { phoneNode.name = "vodafoneTextNode" } }
    var businessCardScene:SCNScene!
   
    var nameTimer: Timer?
    var time = 0
    
    
    init(for node:SCNNode) {
        super.init()
        guard let businessCardScene = SCNScene(named: "art.scnassets/card.scn"),
            let cardRoot = businessCardScene.rootNode.childNode(withName: "RootNode", recursively: false),
            let facebookNode = businessCardScene.rootNode.childNode(withName: "facebook", recursively: true),
            let phoneNode = businessCardScene.rootNode.childNode(withName: "phone", recursively: true),
            let saveContactNode = businessCardScene.rootNode.childNode(withName: "saveContact", recursively: true),
            let message = businessCardScene.rootNode.childNode(withName: "message", recursively: true),

            let vodafoneTextNode = businessCardScene.rootNode.childNode(withName: "vodafone", recursively: true)?.geometry as? SCNText
            else {
                fatalError("Couldn't initialize 3D Nodes")
        }
        self.businessCardScene = businessCardScene
        self.facebookNode = facebookNode
        self.phoneNode = phoneNode
        self.vodafoneTextNode = vodafoneTextNode
        self.cardRoot = cardRoot
        cardRoot.transform = node.transform
        self.addChildNode(cardRoot)
        self.eulerAngles.x = -.pi / 2
        self.eulerAngles.y = -.pi / 2
        let particle = SCNParticleSystem(named: "particle.scnp", inDirectory: nil)!
        let particleNode = SCNNode()
        particleNode.eulerAngles.x = .pi / 2
        self.addChildNode(particleNode)
        particleNode.addParticleSystem(particle)
        interactiveButtons.append(facebookNode)
        interactiveButtons.append(phoneNode)
        interactiveButtons.append(saveContactNode)
        interactiveButtons.append(message)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWebView() {
        
//
//        let videoNode = SKVideoNode(fileNamed: "vodafone.mp4")
//        videoNode.play()
//
//        let skScene = SKScene(size: CGSize(width: 640, height: 480))
//        skScene.addChild(videoNode)
//
//        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
//        videoNode.size = skScene.size
//
//        DispatchQueue.main.async {
//            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
//            let request = URLRequest(url: URL(string: "https://www.vodafone.com")!)
//            
//            webView.load(request)
//            let tvPlane = SCNPlane(width: 0.1, height: 0.1)
//            tvPlane.firstMaterial?.diffuse.contents = webView
//            tvPlane.firstMaterial?.isDoubleSided = true
//            
//            let tvPlaneNode = SCNNode(geometry: tvPlane)
//            tvPlaneNode.position = SCNVector3(0.127, 0, 0)
//            
//            self.cardRoot.addChildNode(tvPlaneNode)
//            
//        }
       
        
    }
    
    /// Removes All SCNMaterials & Geometries From An SCNNode
    func flushFromMemory(){
        
        print("Cleaning Business Card")
        for node in self.childNodes {
            node.removeFromParentNode()
        }
        if let parentNodes = self.parent?.childNodes{ parentNodes.forEach {
            $0.removeFromParentNode()
            }
        }
    }
    
    func setBaseConfiguration() {
        nameTimer?.invalidate()
        time = 0
        vodafoneTextNode.string = ""
        self.interactiveButtons.forEach{ $0.rotation = self.Flipped_Rotation }
        setupWebView()

    }
    func animateBusinessCard() {
        let rotationAsRadian = CGFloat(GLKMathDegreesToRadians(180))
        let flipAction = SCNAction.rotate(by: rotationAsRadian, around: SCNVector3(0, 1, 0), duration: 1.5)
        self.animateTextGeometry(vodafoneTextNode, forName: "Vodafone UK") {
          
        }
        self.interactiveButtons.forEach {
            $0.runAction(flipAction)
        }

    }
    
    func animateTextGeometry(_ textGeometry: SCNText, forName name: String, completed: @escaping () -> Void ){
        
        let characters = Array(name)
        
        nameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            
            if self?.time != characters.count {
                let currentText: String = textGeometry.string as! String
                textGeometry.string = currentText + String(characters[(self?.time)!])
                self?.time += 1
            }else{
                //b. Invalide The Timer, Reset The Variables & Escape
                timer.invalidate()
                self?.time = 0
                completed()
            }
        }
    }
    deinit {
        flushFromMemory()
    }
}
