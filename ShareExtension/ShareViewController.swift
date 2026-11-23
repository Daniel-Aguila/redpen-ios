//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Daniel Aguila on 11/22/26.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            let text = await loadSharedText()
            let root = ShareView(
                original: text,
                onSave: { [weak self] original, corrected in
                    ShareInbox.add(SharedCorrection(original: original, corrected: corrected, date: .now))
                    self?.extensionContext?.completeRequest(returningItems: nil)
                },
                onCancel: { [weak self] in
                    self?.extensionContext?.cancelRequest(withError: CocoaError(.userCancelled))
                }
            )
            let host = UIHostingController(rootView: root)
            addChild(host)
            host.view.frame = view.bounds
            host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(host.view)
            host.didMove(toParent: self)
        }
    }
    
    private func loadSharedText() async -> String {
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        let providers = items.flatMap { $0.attachments ?? [] }
        let type = UTType.plainText.identifier
        for provider in providers where provider.hasItemConformingToTypeIdentifier(type) {
            if let text = try? await provider.loadItem(forTypeIdentifier: type) as? String {
                return text
            }
        }
        return ""
    }
}
