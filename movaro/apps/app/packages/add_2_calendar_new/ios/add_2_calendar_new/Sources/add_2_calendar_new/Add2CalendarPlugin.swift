import EventKit
import EventKitUI
import Flutter
import Foundation
import UIKit

extension Date {
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

private var statusBarStyle = UIApplication.shared.statusBarStyle

public class Add2CalendarPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "add_2_calendar_new",
            binaryMessenger: registrar.messenger()
        )
        let instance = Add2CalendarPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "add2Cal" else {
            result(FlutterMethodNotImplemented)
            return
        }

        let arguments = call.arguments as! [String: Any]
        addEventToCalendar(from: arguments) { success in
            result(success)
        }
    }

    private func addEventToCalendar(
        from arguments: [String: Any],
        completion: ((_ success: Bool) -> Void)? = nil
    ) {
        let title = arguments["title"] as! String
        let description = arguments["desc"] is NSNull ? nil : arguments["desc"] as! String
        let location = arguments["location"] is NSNull ? nil : arguments["location"] as! String
        let timeZone = arguments["timeZone"] is NSNull
            ? nil
            : TimeZone(identifier: arguments["timeZone"] as! String)
        let startDate = Date(milliseconds: arguments["startDate"] as! Double)
        let endDate = Date(milliseconds: arguments["endDate"] as! Double)
        let alarmInterval = arguments["alarmInterval"] as? Double
        let allDay = arguments["allDay"] as! Bool
        let url = arguments["url"] as? String

        let eventStore = EKEventStore()
        let event = createEvent(
            eventStore: eventStore,
            alarmInterval: alarmInterval,
            title: title,
            description: description,
            location: location,
            timeZone: timeZone,
            startDate: startDate,
            endDate: endDate,
            allDay: allDay,
            url: url,
            arguments: arguments
        )

        presentCalendarModalToAddEvent(
            event,
            eventStore: eventStore,
            completion: completion
        )
    }

    private func createEvent(
        eventStore: EKEventStore,
        alarmInterval: Double?,
        title: String,
        description: String?,
        location: String?,
        timeZone: TimeZone?,
        startDate: Date,
        endDate: Date,
        allDay: Bool,
        url: String?,
        arguments: [String: Any]
    ) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        if let alarmInterval {
            event.addAlarm(EKAlarm(relativeOffset: -alarmInterval))
        }
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.timeZone = timeZone
        event.location = location
        event.notes = description
        if let url {
            event.url = URL(string: url)
        }
        event.isAllDay = allDay

        if let recurrence = arguments["recurrence"] as? [String: Any] {
            let interval = recurrence["interval"] as! Int
            let frequency = recurrence["frequency"] as! Int
            let endDate = recurrence["endDate"] as? Double
            let occurrences = recurrence["ocurrences"] as? Int
            let recurrenceEnd = occurrences.map(EKRecurrenceEnd.init(occurrenceCount:))
                ?? endDate.map { EKRecurrenceEnd(end: Date(milliseconds: $0)) }

            event.recurrenceRules = [
                EKRecurrenceRule(
                    recurrenceWith: EKRecurrenceFrequency(rawValue: frequency)!,
                    interval: interval,
                    end: recurrenceEnd
                )
            ]
        }

        return event
    }

    private func authorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    private func presentCalendarModalToAddEvent(
        _ event: EKEvent,
        eventStore: EKEventStore,
        completion: ((_ success: Bool) -> Void)? = nil
    ) {
        if #available(iOS 17, *) {
            OperationQueue.main.addOperation {
                self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
            }
            completion?(true)
            return
        }

        switch authorizationStatus() {
        case .authorized:
            OperationQueue.main.addOperation {
                self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
            }
            completion?(true)
        case .notDetermined:
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                if granted {
                    OperationQueue.main.addOperation {
                        self?.presentEventCalendarDetailModal(
                            event: event,
                            eventStore: eventStore
                        )
                    }
                }
                completion?(granted)
            }
        case .denied, .restricted:
            completion?(false)
        default:
            completion?(false)
        }
    }

    private func presentEventCalendarDetailModal(
        event: EKEvent,
        eventStore: EKEventStore
    ) {
        let eventModalViewController = EKEventEditViewController()
        eventModalViewController.event = event
        eventModalViewController.eventStore = eventStore
        eventModalViewController.editViewDelegate = self
        eventModalViewController.modalPresentationStyle = .fullScreen

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        rootViewController.present(eventModalViewController, animated: true) {
            statusBarStyle = UIApplication.shared.statusBarStyle
            UIApplication.shared.statusBarStyle = .default
        }
    }
}

extension Add2CalendarPlugin: EKEventEditViewDelegate {
    public func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction
    ) {
        controller.dismiss(animated: true) {
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
    }
}
