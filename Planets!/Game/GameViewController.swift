//
//  GameViewController.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var universe: Universe!
    var velocity: CGPoint = .zero
    var pan: UIPanGestureRecognizer!
    var tap: UITapGestureRecognizer!
    var hud: HUD!
    
    let initialColor = UIColor.rgb(90, 50, 180)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        universe = Universe(radius: 20)
        view.backgroundColor = initialColor

        guard let view = view as? SCNView else { return }
        view.scene = universe
        view.allowsCameraControl = false
        view.antialiasingMode = .multisampling4X
        view.delegate = self
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(pan(with:)))
        view.addGestureRecognizer(pan)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tap(with:)))
        view.addGestureRecognizer(tap)
        
        hud = HUD()
        hud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hud)
        
        hud.frame(to: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateTexture(for: initialColor)
    }
    
    func pan(with gesture: UIPanGestureRecognizer) {
        velocity = gesture.velocity(in: gesture.view)
    }
    
    func tap(with gesture: UITapGestureRecognizer) {
        generateTexture(for: UIColor.random())
    }
    
    func generateTexture(for color: UIColor) {
        tap.isEnabled = false
        
        Texture.generate(for: color, progress: hud.loader.progress) { texture in
            self.view.backgroundColor = texture.color
            self.universe.sun.light?.color = texture.color
            
            guard let material = self.universe.planet.geometry?.firstMaterial else { return }
            material.lightingModel = .physicallyBased
            material.diffuse.contents = texture.diffuse
            material.roughness.contents = texture.diffuse
            material.metalness.contents = texture.metalness
            material.normal.contents = texture.normal
            material.specular.contents = texture.color
            
            let generator = PlanetNameGenerator()
            let planetName = generator.generatePlanetName()
            
            self.hud.loader.progress(1.0)
            self.hud.title.text = planetName
            self.tap.isEnabled = true
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard !velocity.equalTo(.zero) else {
            return
        }
        
        let scale: CGFloat = 10000
        let decelerationRate: CGFloat = 0.97
        
        let currentRotation = universe.camera.rotation
        var rotation = GLKQuaternionMakeWithAngleAndAxis(currentRotation.w, currentRotation.x, currentRotation.y, currentRotation.z)
        let rotationX = GLKQuaternionMakeWithAngleAndAxis(Float(-velocity.x / scale), 0, 1, 0)
        let rotationY = GLKQuaternionMakeWithAngleAndAxis(Float(-velocity.y / scale), 1, 0, 0)
        let multipliedRotation = GLKQuaternionMultiply(rotationX, rotationY)
        rotation = GLKQuaternionMultiply(rotation, multipliedRotation)
        
        let axis = GLKQuaternionAxis(rotation)
        let angle = GLKQuaternionAngle(rotation)
        universe.camera.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
        
        if abs(velocity.x) < 1 {
            velocity.x = 0
        } else {
            velocity.x += velocity.x > 0 ? -1 : 1
        }
        
        if velocity.y > -1 && velocity.y < 1 {
            velocity.y = 0
        } else {
            velocity.y += velocity.y > 0 ? -1 : 1
        }
        
        velocity.x *= decelerationRate
        velocity.y *= decelerationRate
    }
}
