//
//  ViewController+Session.swift
//  VodafoneBusinessCard
//
//  Created by Kiro on 12/5/18.
//  Copyright © 2018 Kiro. All rights reserved.
//

import Foundation
import ARKit

extension ViewController: ARSCNViewDelegate,ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if menuShown { return }
        
        //1. Enumerate Our Anchors To See If We Have Found Our Target Anchor
        for anchor in anchors{
            
            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor{
                
                //2. If The ImageAnchor Is No Longer Tracked Then Reset The Business Card
                if !imageAnchor.isTracked {
                    businessCardPlaced = false
                    businessCardNode.setBaseConfiguration()
               
                }else{
                    
                    //3. Layout The Card Again
                    if !businessCardPlaced{
                        businessCardNode.animateBusinessCard()
                        businessCardPlaced = true
                    }
                }
            }
        }
        
    }
}
