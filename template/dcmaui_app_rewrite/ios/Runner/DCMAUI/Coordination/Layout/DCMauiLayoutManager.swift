import UIKit
import yoga

/// Manages layout for DCMAUI components
/// Note: Primary layout calculations occur on the Dart side
/// This class primarily handles applying calculated layouts and handling absolute positioning
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
    // Set of views using absolute layout (controlled by Dart)
    private var absoluteLayoutViews = Set<UIView>()
    
    // Map view IDs to actual UIViews for direct access
    private var viewRegistry = [String: UIView]()
    
    // ADDED: For optimizing layout updates
    private var pendingLayouts = [String: CGRect]()
    private var isLayoutUpdateScheduled = false
    
    // ADDED: Dedicated queue for layout operations
    private let layoutQueue = DispatchQueue(label: "com.dcmaui.layoutQueue", qos: .userInitiated)
    
    private init() {}
    
    // MARK: - View Registry Management
    
    /// Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        viewRegistry[viewId] = view
    }
    
    /// Unregister a view
    func unregisterView(withId viewId: String) {
        viewRegistry.removeValue(forKey: viewId)
    }
    
    /// Get view by ID
    func getView(withId viewId: String) -> UIView? {
        return viewRegistry[viewId]
    }
    
    // MARK: - Absolute Layout Management
    
    /// Mark a view as using absolute layout (controlled by Dart side)
    func setViewUsingAbsoluteLayout(view: UIView) {
        absoluteLayoutViews.insert(view)
    }
    
    /// Check if a view uses absolute layout
    func isUsingAbsoluteLayout(_ view: UIView) -> Bool {
        return absoluteLayoutViews.contains(view)
    }
    
    // MARK: - Cleanup
    
    /// Clean up resources for a view
    func cleanUp(viewId: String) {
        if let view = viewRegistry[viewId] {
            absoluteLayoutViews.remove(view)
        }
        viewRegistry.removeValue(forKey: viewId)
    }
    
    // MARK: - Style Application
    
    /// Apply styles to a view (using the shared UIView extension)
    func applyStyles(to view: UIView, props: [String: Any]) {
        view.applyStyles(props: props)
    }
    
    // MARK: - Layout Management
    
    /// Queue layout update to happen off the main thread
    func queueLayoutUpdate(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard viewRegistry[viewId] != nil else {
            print("❌ Layout Error: View not found for ID \(viewId)")
            return false
        }
        
        // Store layout in pending queue
        let frame = CGRect(x: left, y: top, width: max(1, width), height: max(1, height))
        
        // Use layout queue to modify shared data
        layoutQueue.async {
            self.pendingLayouts[viewId] = frame
            
            if !self.isLayoutUpdateScheduled {
                self.isLayoutUpdateScheduled = true
                
                // Schedule layout application on main thread
                DispatchQueue.main.async {
                    self.applyPendingLayouts()
                }
            }
        }
        
        return true
    }
    
    /// Apply calculated layout to a view with optional animation
    @discardableResult
    func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat, 
                     animationDuration: TimeInterval = 0.0) -> Bool {
        guard let view = getView(withId: viewId) else {
            print("❌ Layout Error: View not found for ID \(viewId)")
            return false
        }
        
        // Create valid frame with minimum dimensions to ensure visibility
        let frame = CGRect(
            x: left,
            y: top,
            width: max(1, width),
            height: max(1, height)
        )
        
        // Apply on main thread
        if Thread.isMainThread {
            if animationDuration > 0 {
                UIView.animate(withDuration: animationDuration) {
                    self.applyLayoutDirectly(to: view, frame: frame)
                }
            } else {
                self.applyLayoutDirectly(to: view, frame: frame)
            }
        } else {
            // Schedule on main thread
            DispatchQueue.main.async {
                if animationDuration > 0 {
                    UIView.animate(withDuration: animationDuration) {
                        self.applyLayoutDirectly(to: view, frame: frame)
                    }
                } else {
                    self.applyLayoutDirectly(to: view, frame: frame)
                }
            }
        }
        
        return true
    }
    
    // Direct layout application helper
    private func applyLayoutDirectly(to view: UIView, frame: CGRect) {
        // Ensure minimum dimensions
        var safeFrame = frame
        safeFrame.size.width = max(1, frame.width)
        safeFrame.size.height = max(1, frame.height)
        
        // Make sure view is visible
        view.isHidden = false
        view.alpha = 1.0
        
        // Set frame directly for best performance
        view.frame = safeFrame
        
        // Force layout
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // New method to batch process layout updates
    private func applyPendingLayouts(animationDuration: TimeInterval = 0.0) {
        // Must be called on main thread
        assert(Thread.isMainThread, "applyPendingLayouts must be called on the main thread")
        
        // Reset flag first
        isLayoutUpdateScheduled = false
        
        // Make local copy to prevent concurrency issues
        var layoutsToApply: [String: CGRect] = [:]
        
        // Use layoutQueue to safely get pending layouts
        layoutQueue.sync {
            layoutsToApply = self.pendingLayouts
            self.pendingLayouts.removeAll()
        }
        
        // Apply all pending layouts
        if animationDuration > 0 {
            UIView.animate(withDuration: animationDuration) {
                for (viewId, frame) in layoutsToApply {
                    if let view = self.getView(withId: viewId) {
                        self.applyLayoutDirectly(to: view, frame: frame)
                    }
                }
            }
        } else {
            for (viewId, frame) in layoutsToApply {
                if let view = self.getView(withId: viewId) {
                    self.applyLayoutDirectly(to: view, frame: frame)
                }
            }
        }
    }
}
