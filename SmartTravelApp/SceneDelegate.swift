import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Invoked when a new scene connection is being established.
    /// This is where you configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    /// If the app uses a storyboard, the `window` property is automatically initialized and attached to the scene.
    /// This method is not an indication that the scene or session are newly created; for new scenes, refer to `application:configurationForConnectingSceneSession`.
    /// - Parameters:
    ///   - scene: An object representing the scene to be connected.
    ///   - session: The scene session associated with the connection.
    ///   - connectionOptions: Options related to the connection process, such as user activities or notifications that triggered the scene connection.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    /// Called when a scene is disconnected and no longer visible to the user.
    /// This method is invoked when the scene enters the background or its session is discarded.
    /// Use this method to release any resources associated with this scene, as they can be recreated the next time the scene connects.
    /// Note that this method is called before the scene is completely discarded and may still reconnect.
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    /// Called when the scene transitions from an inactive state to an active state.
    /// Use this method to restart tasks that were paused (or not started) while the scene was inactive.
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    /// Called when the scene is about to move from an active state to an inactive state.
    /// This can occur due to temporary interruptions (e.g., an incoming phone call).
    func sceneWillResignActive(_ scene: UIScene) {
    }

    /// Called as the scene transitions from the background to the foreground.
    /// Use this method to reverse changes made when the scene entered the background.
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    /// Called as the scene transitions from the foreground to the background.
    /// Use this method to save data, release shared resources, and store enough scene-specific state information to restore the scene back to its current state upon reentry.
    /// This method also saves changes in the application's managed object context when the application transitions to the background, ensuring that all unsaved changes are persisted.
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

