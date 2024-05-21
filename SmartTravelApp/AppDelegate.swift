import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var test = "123"
    /// Invoked when the application is about to start. This is the entry point for the application's initialization.
    /// - Parameters:
    ///   - application: The singleton application instance.
    ///   - launchOptions: A dictionary containing the reasons the application was launched (if any).
    /// - Returns: A Boolean value indicating if the application should continue with the usual launch process.
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set the delegate for handling notifications
        notificationCenter.delegate = self
        
        // Define notification authorization options
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        // Request permission from the user to display notifications
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        return true
    }


    // MARK: UISceneSession Lifecycle

    /// Called when a new UIScene session is being created.
    /// Use this method to select a configuration to create the new scene with.
    /// - Parameters:
    ///   - application: The singleton application instance.
    ///   - connectingSceneSession: The UISceneSession being connected.
    ///   - options: Options specifying how the scene was requested.
    /// - Returns: The configuration data for the new scene.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Return a scene configuration object specifying the configuration for the new scene.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Called when the user discards a UIScene session.
    /// Use this method to release any resources that were specific to the discarded scene, as they will not return.
    /// - Parameter sceneSessions: The set of UISceneSession objects that were discarded.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Implement this method to handle any cleanup after the discarded scene sessions.
    }

    // MARK: - Core Data stack

    /// The persistent container for the application. It encapsulates the Core Data stack, handling the creation and management of the managed object model, persistent store coordinator, and the managed object context.
    lazy var persistentContainer: NSPersistentContainer = {
        // Create and return a container, having loaded the store for the application.
        let container = NSPersistentContainer(name: "SmartTravelApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error appropriately instead of crashing.
                // Common reasons for errors include the parent directory not being accessible, the device running out of space, or the store being locked due to device encryption.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    /// Saves changes in the application's managed object context before the application terminates.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // Attempt to save any changes to the context.
                try context.save()
            } catch {
                // Handle the error appropriately instead of crashing.
                // It's important not to use fatalError() in a shipping application.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Indicate how to present the notification when the app is in the foreground
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Handle actions when a notification is received while the app is in the foreground
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        // Call the completion handler to signal that the task is complete
        completionHandler()
    }

    func scheduleNotification(notificationType: String) {
        
        // Create notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "Delete Notification Type"
        
        content.title = notificationType
        content.body =  notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier
        
        // Create notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        // Define notification actions
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        // Set notification categories
        notificationCenter.setNotificationCategories([category])
    }



}


