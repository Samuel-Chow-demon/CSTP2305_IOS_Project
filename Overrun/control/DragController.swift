//
//  DragController.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.
//

import Foundation
import UIKit
import SwiftUI
import SpriteKit

class DragController{
    
    //Closures for drag events
    var onDragBegan: ((CGPoint)->Void)?
    var onDragChanged: ((CGFloat, CGFloat, CGFloat)->Void)?
    var onDragEnded: (()->Void)?
    var onDragCancelled: (()->Void)?
    
    var startCGPoint: CGPoint? = nil
    
    private var dx: CGFloat = 0
    private var dy: CGFloat = 0
    private var persisAngle: CGFloat = 0
    private var isDragging: Bool = false
    
    func startBackgroundLoop()
    {
        self.isDragging = true
        
        DispatchQueue.global(qos: .background).async
        {
            while self.isDragging {
                let startTime = Date()
            
                //print("Dragging Handle on going")
                self.onDragChanged?(self.persisAngle, self.dy, self.dx)
                
                // Wait for the next frame, roughly 60 FPS
                let timeElapsed = Date().timeIntervalSince(startTime)
                let sleepTime = max(0, 1/60 - timeElapsed)
                usleep(useconds_t(sleepTime * 1000000))  // Convert to microseconds
            }
            
            DispatchQueue.main.async {
                // This will run when the loop is stopped
                
            }
        }
    }
    
    @objc func HandleDrag(_ gesture: UIPanGestureRecognizer){
        
        // for gesture, the coordinate is different, the (0,0) is top left, so
        // move right is +ve, move down is +ve
        let location = gesture.location(in: gesture.view)
        let screenHeight = UIScreen.main.bounds.height
        let currentCGPoint = CGPoint(x: location.x, y: screenHeight - location.y) // flip back to follow the world coord use bottom left (0,0)
        
        switch gesture.state{
            
            case .began:
                startCGPoint = currentCGPoint
                onDragBegan?(currentCGPoint)
                
            case .changed:
                
                if let startPos = startCGPoint{
                    
                    dx = currentCGPoint.x - startPos.x
                    dy = (currentCGPoint.y - startPos.y)
                    persisAngle = atan2(dy, dx)
                    
                    //print("current : \(currentCGPoint), start : \(startPos)")
                    
                    if (!isDragging)
                    {
                        startBackgroundLoop()
                    }
                }
                
            case .ended:
            
                isDragging = false
                onDragEnded?()
                
            case .cancelled:
            
                isDragging = false
                onDragCancelled?()
                
            default:
                break
        }
    }
}

// Triangle Path
func DragArrowPath(in rect: CGRect, angle: CGFloat)->UIBezierPath{
    let path = UIBezierPath()
    
    // Size
    let length: CGFloat = Constant.DRAG_ARROW_HEIGHT
    let baseWidth: CGFloat = Constant.DRAG_ARROW_WIDTH
    
    let tipX = cos(angle) * length
    let tipY = sin(angle) * length
    
    // Calculate base points (perpendicular to the direction)
    let baseX1 = cos(angle + .pi / 2) * baseWidth
    let baseY1 = sin(angle + .pi / 2) * baseWidth
    let baseX2 = cos(angle - .pi / 2) * baseWidth
    let baseY2 = sin(angle - .pi / 2) * baseWidth
    
    // Draw the triangle
    path.move(to: CGPoint(x: tipX, y: tipY))         // to tip
    path.addLine(to: CGPoint(x: baseX1, y: baseY1))     // to base left
    path.addLine(to: CGPoint(x: baseX2, y: baseY2))     // Base right
    path.close() // Close the triangle
    
    return path
}

// Custom gradient shader
let gradientShader = SKShader(source: """
    void main() {
        // Get the fragment position
        vec2 position = v_tex_coord;

        // The base color and tip color (use your desired colors)
        vec4 baseColor = vec4(0.5, 0.5, 0.5, 0.8); // Medium at the base, 0.8 opacity
        vec4 tipColor = vec4(0.7, 0.7, 0.7, 0.2); // light grey at the tip
        
        // Create a gradient effect by adjusting the color based on Y position
        float gradient = position.y;
        gl_FragColor = mix(baseColor, tipColor, gradient);
    }
""")
