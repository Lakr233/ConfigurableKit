//
//  SceneDelegate.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/4.
//

import Combine
import ConfigurableKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var cancellables = Set<AnyCancellable>()

    @BareCodableStorage(key: "Test.BareCodableStorage", defaultValue: false)
    var testBareCodableStorage: Bool

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        #if targetEnvironment(macCatalyst)
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.toolbar = nil
            }
        #endif
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1024, height: 768)

        testBareCodableStorage = true
        assert(testBareCodableStorage)
        testBareCodableStorage = false
        assert(!testBareCodableStorage)

        ConfigurableKit.publisher(forKey: "theme", type: String.self)
            .sink { [weak self] input in
                guard let window = self?.window,
                      let input,
                      let theme = InterfaceStyle(rawValue: input)
                else { return }

                window.overrideUserInterfaceStyle = theme.style

                let appearance = theme.appearance
                let setAppearanceSelector = Selector(("setAppearance:"))
                guard let app = (NSClassFromString("NSApplication") as? NSObject.Type)?
                    .value(forKey: "sharedApplication") as? NSObject,
                    app.responds(to: setAppearanceSelector)
                else { return }
                app.perform(setAppearanceSelector, with: appearance)
            }
            .store(in: &cancellables)
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
