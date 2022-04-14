//
// Square.swift
//

import UIKit
import Extensions

open class Square: UIControl {
    
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
    
    open var isContinuous = true
    
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
            return CGPoint(
                x: isUseX ? position.x / frame.width : .nan,
                y: isUseY ? position.y / frame.height : .nan
            )
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
    
    open var preferredEdgeInsets: UIEdgeInsets {
        return .zero
    }
    
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
    
    private lazy var edgeInsets: UIEdgeInsets = preferredEdgeInsets
    
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
    
    // MARK: - Open func
    
    open func update(with point: CGPoint) {
        CALayer.performWithoutAnimation {
            thumbLayer.position = CGPoint(
                x: (isUseX ? point.x : 0.5) * frame.width,
                y: (isUseY ? point.y : 0.5) * frame.height
            )
        }
    }
    
    // MARK: - Private func
    
    private func setup() {
        for trackLayer in trackLayers {
            layer.addSublayer(trackLayer)
        }
        layer.addSublayer(thumbLayer)
    }
    
    private func point(by touch: UITouch) -> CGPoint {
        let point = touch.location(in: self)
        let result = CGPoint(
            x: point.x / frame.width,
            y: point.y / frame.height
        )
        return result.bounded
    }
}
