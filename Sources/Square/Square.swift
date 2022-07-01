//
// Square.swift
//

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import Cocoa
#endif

import Extensions

#if os(iOS)
public typealias Control = UIControl
#endif

#if os(macOS)
public typealias Control = NSControl
#endif

open class Square: Control {
    
    // MARK: - Public struct
    
    public struct Axis: OptionSet {
        
        // MARK: - Public static var
        
        public static var x: Axis {
            return Axis(rawValue: 1 << 0)
        }
        
        public static var y: Axis {
            return Axis(rawValue: 1 << 1)
        }
        
        public static var all: Axis {
            return [
                .x,
                .y
            ]
        }
        
        // MARK: - OptionSet
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    // MARK: - Open var
    
#if os(iOS)
    
    open var isContinuous = true
    
#endif
    
#if os(macOS)
    
    open var isTracking = false
    
#endif
    
    open var value: CGFloat {
        get {
            switch axis {
            case .x:
                return point.x
            case .y:
                return point.y
            default:
                return .nan
            }
        }
        set {
            switch axis {
            case .x:
                point = CGPoint(
                    x: newValue,
                    y: 0.0
                )
            case .y:
                point = CGPoint(
                    x: 0.0,
                    y: newValue
                )
            default:
                break
            }
        }
    }
    
    open var point: CGPoint {
        get {
            let position = thumbLayer.position
            let x = isUseX ? position.x / frame.width : .nan
#if os(iOS)
            let y = isUseY ? position.y / frame.height : .nan
#endif
#if os(macOS)
            let y = isUseY ? 1.0 - (position.y / frame.height) : .nan
#endif
            return CGPoint(x: x, y: y)
        }
        set {
            if isTracking {
                return
            }
            update(with: newValue.bounded)
            saved = point
        }
    }
    
    open var preferredAxis: Axis {
        return []
    }
    
    open var preferredTrackLayers: [CALayer] {
        return []
    }
    
    open var preferredThumbLayer: CALayer {
        return CALayer()
    }
    
#if os(iOS)
    
    open var preferredEdgeInsets: UIEdgeInsets {
        return .zero
    }
    
#endif
    
    // MARK: - Private var
    
    private var saved = CGPoint.zero
    
    private var isDragging = false
    
    private var isUseX: Bool {
        return axis.contains(.x)
    }
    
    private var isUseY: Bool {
        return axis.contains(.y)
    }
    
    // MARK: - Private lazy var
    
    private lazy var axis: Axis = preferredAxis
    
    private lazy var trackLayers: [CALayer] = preferredTrackLayers
    
    private lazy var thumbLayer: CALayer = preferredThumbLayer
    
#if os(iOS)
    
    private lazy var edgeInsets: UIEdgeInsets = preferredEdgeInsets
    
#endif
    
    // MARK: - Public override init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Open override func
    
#if os(iOS)
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        for trackLayer in trackLayers {
            trackLayer.frame = bounds
        }
        update(with: saved)
    }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        update(with: point(by: touch))
        saved = point
        sendActions(for: .valueChanged)
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        update(with: point(by: touch))
        saved = point
        if isContinuous {
            sendActions(for: .valueChanged)
        }
        isDragging = true
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if !isContinuous && isDragging {
            sendActions(for: .valueChanged)
        }
        isDragging = false
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return bounds.inset(by: edgeInsets).contains(point) ? self : nil
    }
    
#endif
    
#if os(macOS)
    
    open override func layout() {
        super.layout()
        for trackLayer in trackLayers {
            trackLayer.frame = bounds
        }
        update(with: saved)
    }
    
    open override func mouseDown(with event: NSEvent) {
        isTracking = true
        update(with: point(by: event))
        saved = point
        sendAction(action, to: target)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        if !isTracking {
            return
        }
        update(with: point(by: event))
        saved = point
        if isContinuous {
            sendAction(action, to: target)
        }
        isDragging = true
    }
    
    open override func mouseUp(with event: NSEvent) {
        if !isContinuous && isDragging {
            sendAction(action, to: target)
        }
        isDragging = false
        isTracking = false
    }
    
#endif
    
    // MARK: - Open func
    
    open func update(with point: CGPoint) {
        let x = (isUseX ? point.x : 0.5) * frame.width
#if os(iOS)
        let y = (isUseY ? point.y : 0.5) * frame.height
#endif
#if os(macOS)
        let y = (isUseY ? (1.0 - point.y) : 0.5) * frame.height
#endif
        CALayer.performWithoutAnimation {
            thumbLayer.position = CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Private func
    
    private func setup() {
#if os(iOS)
        for trackLayer in trackLayers {
            layer.addSublayer(trackLayer)
        }
        layer.addSublayer(thumbLayer)
#endif
#if os(macOS)
        layer = CALayer()
        layer?.masksToBounds = false
        for trackLayer in trackLayers {
            layer?.addSublayer(trackLayer)
        }
        layer?.addSublayer(thumbLayer)
#endif
    }
    
#if os(iOS)
    
    private func point(by touch: UITouch) -> CGPoint {
        let point = touch.location(in: self)
        return boundedPoint(with: point)
    }
    
#endif
    
#if os(macOS)
    
    private func point(by event: NSEvent) -> CGPoint {
        let point = convert(event.locationInWindow, from: nil)
        return boundedPoint(with: point)
    }
    
#endif
    
    private func boundedPoint(with point: CGPoint) -> CGPoint {
        let x = point.x / frame.width
        let y = point.y / frame.height
        let result = CGPoint(x: x, y: y).bounded
#if os(iOS)
        return result
#endif
#if os(macOS)
        return CGPoint(
            x: result.x,
            y: 1.0 - result.y
        )
#endif
    }
}
