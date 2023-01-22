//
//  Home.swift
//  NativePopovers
//
//  Created by Berkay Disli on 22.01.2023.
//

import SwiftUI

struct Home: View {
    @State private var showPopover = false
    @State private var updateText = false
    var body: some View {
        Button("Show Popover") {
            showPopover.toggle()
        }
        .iOSPopover(isPresented: $showPopover, arrowDirection: .up) {
            VStack(spacing: 12) {
                Text("This is \(updateText ? "an updated popover":"a popover").")
                
                Button("Update Text") {
                    updateText.toggle()
                }
                Button("Close") {
                    showPopover.toggle()
                }
            }
            //.foregroundColor(.white)
            .padding(15)
            /*
            .background {
                Rectangle()
                    .fill(.green)
                    .padding(-20)
                    
            }
             */
        }
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    @ViewBuilder
    func iOSPopover<Content: View>(isPresented: Binding<Bool>, arrowDirection: UIPopoverArrowDirection, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .background {
                PopoverController(isPresented: isPresented, arrowDirection: arrowDirection, content: content())
            }
    }
}

struct PopoverController<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var arrowDirection: UIPopoverArrowDirection
    var content: Content
    @State private var alreadyPresented = false
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if alreadyPresented {
            if let hostingController = uiViewController.presentedViewController as? CustomHostingView<Content> {
                hostingController.rootView = content
                hostingController.preferredContentSize = hostingController.view.intrinsicContentSize
            }
            if !isPresented {
                uiViewController.dismiss(animated: true) {
                    alreadyPresented = false
                }
            }
        } else {
            if isPresented {
                let controller = CustomHostingView(rootView: content)
                controller.view.backgroundColor = .clear
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.permittedArrowDirections = arrowDirection
                
                controller.presentationController?.delegate = context.coordinator
                
                controller.popoverPresentationController?.sourceView = uiViewController.view
                uiViewController.present(controller, animated: true)
            }
        }
    }
    
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        var parent: PopoverController
        init(parent: PopoverController) {
            self.parent = parent
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }
        
        func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
            DispatchQueue.main.async {
                self.parent.alreadyPresented = true
            }
        }
    }
}

class CustomHostingView<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.intrinsicContentSize
    }
}


