import UIKit

open class BlurView: UIVisualEffectView {
    
    public init(style: UIBlurEffect.Style) {
        super.init(effect: UIBlurEffect(style: style))
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public var blurRadius: CGFloat {
        get {
            gaussianBlurFilter?.dictionaryValue(getter: "requestedValues")?["inputRadius"] as? CGFloat ?? 0.0
        }
        set {
            prepareForChanges()
            gaussianBlurFilter?.setObjectInDictionary(object: newValue, key: "inputRadius", getter: "requestedValues")
            applyChanges()
        }
    }

    public var colorTint: UIColor? {
        get {
            sourceOverEffect?.colorValue(getter: "color")
        }
        set {
            prepareForChanges()
            sourceOverEffect?.setValueUsingSetter(value: newValue, getter: "color")
            sourceOverEffect?.callMethod(named: "applyRequestedEffectToView:", with: overlayView)
            applyChanges()
            backgroundColor = newValue
            backdropView?.backgroundColor = newValue
        }
    }
    
    var backdropView: UIView? {
        subviews.first {
            type(of: $0) == NSClassFromString("_UIVisualEffectBackdropView")
        }
    }

    var overlayView: UIView? {
        subviews.first {
            type(of: $0) == NSClassFromString("_UIVisualEffectSubview")
        }
    }

    var gaussianBlurFilter: NSObject? {
        backdropView?.arrayValue(getter: "filters")?.first {
            $0.stringValue(getter: "filterType") == "gaussianBlur"
        }
    }

    var sourceOverEffect: NSObject? {
        overlayView?.arrayValue(getter: "viewEffects")?.first {
            $0.stringValue(getter: "filterType") == "sourceOver"
        }
    }

    func prepareForChanges() {
        gaussianBlurFilter?.setIVarValue(value: 1.0, getter: "requestedScaleHint")
    }

    func applyChanges() {
        backdropView?.callMethod(named: "applyRequestedFilterEffects")
    }
    
}

/// VisualEffectView is a dynamic background blur view.
//open class BlurView: UIVisualEffectView {
//
//    /**
//     Tint color.
//
//     The default value is nil.
//     */
//    open var colorTint: UIColor? {
//        get { return _value(forKey: "colorTint") as? UIColor }
//        set { _setValue(newValue, forKey: "colorTint") }
//    }
//
//    /**
//     Tint color alpha.
//
//     The default value is 0.0.
//     */
//    open var colorTintAlpha: CGFloat {
//        get { return _value(forKey: "colorTintAlpha") as? CGFloat ?? 0 }
//        set { _setValue(newValue, forKey: "colorTintAlpha") }
//    }
//
//    /**
//     Blur radius.
//
//     The default value is 0.0.
//     */
//    open var blurRadius: CGFloat {
//        get { return _value(forKey: "blurRadius") as? CGFloat ?? 0 }
//        set {
//            updateBlurRadius()
//            _setValue(newValue, forKey: "blurRadius")
//        }
//    }
//
//    /**
//     Scale factor.
//
//     The scale factor determines how content in the view is mapped from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
//
//     The default value is 1.0.
//     */
//    open var scale: CGFloat {
//        get { return _value(forKey: "scale") as? CGFloat ?? 1 }
//        set { _setValue(newValue, forKey: "scale") }
//    }
//
//    private var blurEffect: UIBlurEffect!
//
//    // MARK: - Initialization
//
//    public init(style: UIBlurEffect.Style) {
//        let blurEffect = Self.makeBlurEffect(style: .dark)
//
//        super.init(effect: blurEffect)
//
//        self.blurEffect = blurEffect
//
//        commonInit()
//    }
//
//    @available(*, unavailable)
//    required public init?(coder aDecoder: NSCoder) { fatalError() }
//
//    private func commonInit() {
//        scale = 1
//    }
//
//    // MARK: - Helpers
//
//    /// Returns the value for the key on the blurEffect.
//    private func _value(forKey key: String) -> Any? {
//        blurEffect.value(forKeyPath: key)
//    }
//
//    /// Sets the value for the key on the blurEffect.
//    private func _setValue(_ value: Any?, forKey key: String) {
//        if #available(iOS 14, *) {
//            let subviewClass = NSClassFromString("_UIVisualEffectSubview") as? UIView.Type
//            let visualEffectSubview: UIView? = subviews.filter({ type(of: $0) == subviewClass }).first
//            visualEffectSubview?.backgroundColor = colorTint
//            visualEffectSubview?.alpha = colorTintAlpha
//        } else {
//            blurEffect.setValue(value, forKeyPath: key)
//            effect = blurEffect
//        }
//    }
//
//    private static func makeBlurEffect(style: UIBlurEffect.Style) -> UIBlurEffect {
//        if #available(iOS 14, *) {
//            return CustomBlurEffect.effect(with: style)
//        } else {
//            return (NSClassFromString("_UICustomBlurEffect") as? UIBlurEffect.Type)?.init() ?? UIBlurEffect(style: style)
//        }
//    }
//
//    private func updateBlurRadius() {
//        if #available(iOS 14.0, *) {
////            (blurEffect as? CustomBlurEffect)?.blurRadius = blurRadius
////            visualEffectView.removeFromSuperview()
////            let newEffect = CustomBlurEffect.effect(with: .extraLight)
////            newEffect.blurRadius = blurRadius
////            blurEffect = newEffect
////            visualEffectView = UIVisualEffectView(effect: customBlurEffect_ios14)
////            setupViews()
//        }
//    }
//
//}
//
//class CustomBlurEffect: UIBlurEffect {
//
//    var blurRadius: CGFloat = 10.0
//
//    private enum Constants {
//        static let blurRadiusSettingKey = "blurRadius"
//    }
//
//    class func effect(with style: UIBlurEffect.Style) -> CustomBlurEffect {
//        let result = super.init(style: style)
//        object_setClass(result, self)
//        return result as! CustomBlurEffect
//    }
//
//    override func copy(with zone: NSZone? = nil) -> Any {
//        let result = super.copy(with: zone)
//        object_setClass(result, Self.self)
//        return result
//    }
//
//    override var effectSettings: AnyObject {
//        get {
//            let settings = super.effectSettings
//            settings.setValue(blurRadius, forKey: Constants.blurRadiusSettingKey)
//            return settings
//        }
//        set {
//            super.effectSettings = newValue
//        }
//    }
//
//}
//
//extension UIBlurEffect {
//
//    private static var effectSettingsKey: UInt8 = 0
//
//    @objc var effectSettings: AnyObject {
//        get {
//            return objc_getAssociatedObject(self, &Self.effectSettingsKey) as AnyObject
//        }
//        set {
//            objc_setAssociatedObject(self, &Self.effectSettingsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//}
