//
//  TimerView.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 12/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Cocoa
import AppKit

/// ⏰ TimerView is a custom view containing the rendering of the pie chart representing the spent and remaining time.
@IBDesignable class TimerView : NSView {
    
    /// Percent time remaining. When this property is updated indicate that the view should be updated.
    /// - Postcondition: Percent is updated and notification sent to update view
    @IBInspectable var timeRemaining: Double = 0.0 {
        didSet {
            self.needsDisplay = true
        }
    }
    
    @IBAction func clickAction(_ sender: Any) {
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        drawTimer(context: context)
        drawRemainingTime(context: context)
    }
    
    fileprivate struct Constants {
        static let marginToClockFace: CGFloat = 15.0
        static let marginToMinorSecondMarker: CGFloat = 10.0
        static let marginToMajorSecondMarker: CGFloat = 15.0
        static let majorSecondMarkerWidth: CGFloat = 2.5
        static let minorSecondMarkerWidth: CGFloat = 1.0
        static let markerColor: NSColor = NSColor.black
    }
}

// MARK: - Drawing Extension

extension TimerView {
    
    /// Draws the clock face including the markers
    func drawTimer(context: CGContext?) {
        let radius = min(frame.size.width, frame.size.height) * 0.5
        let endAngle = CGFloat(2 * Double.pi)
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        context?.addArc(center: viewCenter, radius: radius, startAngle: 0, endAngle:endAngle, clockwise: true)
        context?.setFillColor(NSColor.white.cgColor)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.setLineWidth(4.0)
        
        context?.fillPath()
        
        
        // Add 60 markers on the clock face (like a normal analog clock)
        for i in 1...60 {
            context?.saveGState()
            // Translate and rotate into positon of next marker
            context?.translateBy(x: frame.midX, y: frame.midY)
            context?.rotate(by: degree2radian(CGFloat(i)*6))
            
            // Determine if it is a major or minor marker
            if i % 5 == 0 {
                drawSecondMarker(ctx: context, x: radius-Constants.marginToMajorSecondMarker, y:0, radius:radius, lineWidth: Constants.majorSecondMarkerWidth, color: Constants.markerColor)
            }
            else {
                drawSecondMarker(ctx: context, x: radius-Constants.marginToMinorSecondMarker, y:0, radius:radius, lineWidth: Constants.minorSecondMarkerWidth, color: Constants.markerColor)
            }
            
            context?.restoreGState()
        }
    }
    
    /// Draws a single second marker on the clock face
    func drawSecondMarker(ctx:CGContext?, x:CGFloat, y:CGFloat, radius:CGFloat, lineWidth:CGFloat, color:NSColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: x, y: y))
        path.closeSubpath()
        ctx?.addPath(path)
        ctx?.setLineWidth(lineWidth)
        ctx?.setStrokeColor(color.cgColor)
        ctx?.strokePath();
    }
    
    /// Draws the pie chart representing the remaining time.
    func drawRemainingTime(context: CGContext?) {
        let radius = min(frame.size.width, frame.size.height) * 0.5 - Constants.marginToClockFace
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        let startAngle = CGFloat.pi / 2
        
        context?.setFillColor(NSColor.pieChartTimeRemainingFillColor.cgColor)
        let endAngle = startAngle + 2 * CGFloat.pi * CGFloat(timeRemaining)
        context?.move(to: viewCenter)
        context?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context?.fillPath()
    }
}

// MARK: - Calculations Extension

extension TimerView {
    
    /// Converts degrees to radian
    func degree2radian(_ a:CGFloat)->CGFloat {
        let b = CGFloat(Double.pi) * a/180
        return b
    }
    
}
