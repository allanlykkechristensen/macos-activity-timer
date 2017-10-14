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
    
    var started = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    /// Margin from the clock face outer circle to the time remaining pie chart
    @IBInspectable var marginToClockFace: CGFloat = 15.0
    /// Margin from the clock face outer circle to the time remaining pie chart
    @IBInspectable var marginToMinorSecondMarker: CGFloat = 10.0
    @IBInspectable var marginToMajorSecondMarker: CGFloat = 15.0
    @IBInspectable var majorSecondMarkerWidth: CGFloat = 2.5
    @IBInspectable var minorSecondMarkerWidth: CGFloat = 1.0
    @IBInspectable var markerColor: NSColor = NSColor.black
    @IBInspectable var backgroundColor: NSColor = NSColor.white
    @IBInspectable var roundedBorderColor: NSColor = NSColor.black
    @IBInspectable var roundedBorderThickness: CGFloat = 10
    @IBInspectable var roundedBorderRadius: CGFloat = 40
    @IBInspectable var timeRemainingColor: NSColor = NSColor.pieChartTimeRemainingFillColor
    
    /// Calculated property returning the center of the circle as as CGPoint
    var viewCenter : CGPoint {
        get {
            return CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        drawTimer(context: context)
        drawRemainingTime(context: context)
        drawBorder(rect: dirtyRect)
        drawClockHand(context: context)
        self.layer?.backgroundColor = backgroundColor.cgColor
        
    }
}

// MARK: - Drawing Extension

extension TimerView {
    
    func drawClockHand(context: CGContext?) {
        let dotRadius = CGFloat(25)
        
        
        // Dot in the middle
        let endAngle = CGFloat(2 * Double.pi)
        context?.addArc(center: viewCenter, radius: dotRadius, startAngle: 0, endAngle:endAngle, clockwise: true)
        context?.setFillColor(NSColor.black.cgColor)
        context?.fillPath()
        
        context?.setFillColor(NSColor.black.cgColor)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y+dotRadius))
        context?.addLine(to: CGPoint(x: viewCenter.x+dotRadius+10, y:viewCenter.y))
        context?.addLine(to: CGPoint(x: viewCenter.x, y:viewCenter.y-dotRadius))
        context?.closePath()
        context?.fillPath()
        
        // Play icon
        context?.setFillColor(NSColor.white.cgColor)
        context?.setStrokeColor(NSColor.white.cgColor)
        if (!started) {
            context?.move(to: viewCenter)
            context?.addLine(to: CGPoint(x: viewCenter.x, y:viewCenter.y + 5))
            context?.addLine(to: CGPoint(x: viewCenter.x+5, y:viewCenter.y))
            context?.addLine(to: CGPoint(x: viewCenter.x, y:viewCenter.y - 5))
            context?.closePath()
            context?.strokePath()
        } else {
            context?.move(to: CGPoint(x: viewCenter.x-3, y: viewCenter.y-10))
            context?.addLine(to: CGPoint(x: viewCenter.x-3, y:viewCenter.y + 10))
            context?.move(to: CGPoint(x: viewCenter.x+3, y: viewCenter.y-10))
            context?.addLine(to: CGPoint(x: viewCenter.x+3, y:viewCenter.y + 10))
            
            context?.strokePath()
        }
    }
    
    
    /// Draws the clock rounded borders
    func drawBorder(rect: NSRect) {
        // Draw border around clock
        let newRect = NSRect(x: rect.origin.x+2, y: rect.origin.y+2, width: rect.size.width-3, height: rect.size.height-3)
        
        let textViewSurround = NSBezierPath(roundedRect: newRect, xRadius: roundedBorderRadius, yRadius: roundedBorderRadius)
        textViewSurround.lineWidth = roundedBorderThickness
        roundedBorderColor.setStroke()
        textViewSurround.stroke()
    }
    
    /// Draws the clock face including the markers
    func drawTimer(context: CGContext?) {
        let radius = min(frame.size.width, frame.size.height) * 0.5 - roundedBorderRadius
        let endAngle = CGFloat(2 * Double.pi)
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
                drawSecondMarker(ctx: context, x: radius-marginToMajorSecondMarker, y:0, radius:radius, lineWidth: majorSecondMarkerWidth, color: markerColor)
            }
            else {
                drawSecondMarker(ctx: context, x: radius-marginToMinorSecondMarker, y:0, radius:radius, lineWidth: minorSecondMarkerWidth, color: markerColor)
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
        let radius = min(frame.size.width, frame.size.height) * 0.5 - marginToClockFace - roundedBorderRadius
        let startAngle = CGFloat.pi / 2
        
        context?.setFillColor(timeRemainingColor.cgColor)
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
