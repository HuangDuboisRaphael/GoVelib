//
//  HalfSheetHelper.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 16/06/2022.
//

import SwiftUI

// To instance a custom UIViewController.
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    
    @Binding var showSheet: Bool
    
    var sheetView: SheetView
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        } else {
            uiViewController.dismiss(animated: true)
        }
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
        }
    }
}

// To render at half-sheet.
class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override func viewDidLoad() {
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
            
            presentationController.prefersGrabberVisible = true
        }
    }
}

// To instance the modal behavior.
extension View {
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView) -> some View {
        return self
            .background(HalfSheetHelper(showSheet: showSheet, sheetView: sheetView()))
    }
}
