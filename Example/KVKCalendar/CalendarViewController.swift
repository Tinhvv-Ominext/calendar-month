//
//  CalendarViewController.swift
//  KVKCalendar_Example
//
//  Created by tinhvv-ominext on 7/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import KVKCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var monthCalendarView: UIView!
    @IBOutlet weak var userListView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var leftWidth: NSLayoutConstraint!
    @IBOutlet weak var selectModeButton: UIButton!
    @IBOutlet weak var eventsView: UIView!
    @IBOutlet weak var closeEventViewButton: UIButton!
    @IBOutlet weak var eventViewTrailing: NSLayoutConstraint!
    
    private var events = [Event]()
    
    private var selectDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: "14.12.2018") ?? Date()
    }()
    
    private lazy var style: Style = {
        var style = Style()
        if UIDevice.current.userInterfaceIdiom == .phone {
            style.month.isHiddenSeporator = true
            style.timeline.widthTime = 40
            style.timeline.offsetTimeX = 2
            style.timeline.offsetLineLeft = 2
        } else {
            style.timeline.widthEventViewer = 300
        }
        style.timeline.startFromFirstEvent = false
        style.followInSystemTheme = true
        style.timeline.offsetTimeY = 80
        style.timeline.offsetEvent = 3
        style.timeline.currentLineHourWidth = 40
        style.allDay.isPinned = false
        style.startWeekDay = .sunday
        style.timeHourSystem = .customize
        style.event.isEnableMoveEvent = true
        return style
    }()
    
    private lazy var calendar: CalendarView = {
        let calendar = CalendarView(frame: calendarView.bounds, date: selectDate, style: style)
        calendar.delegate = self
        calendar.dataSource = self
        return calendar
    }()
    
    private var isShowLeftView = true
    private var mode: CalendarType = .day {
        didSet {
            selectModeButton.setTitle(mode.rawValue, for: .normal)
            calendar.set(type: mode, date: selectDate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.addSubview(calendar)
        loadEvents { [unowned self] (events) in
            self.events = events
            self.calendar.reloadData()
                }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = calendarView.bounds
        frame.origin.y = 0
        calendar.reloadFrame(frame)
    }
    
    private func showLeftView() {
        isShowLeftView = !isShowLeftView
        UIView.animate(withDuration: 0.25) {
            self.leftWidth.constant = self.isShowLeftView ? 300 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func showEventView(_ isShow: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.eventViewTrailing.constant = isShow ? 0 : 260
            self.eventsView.layoutIfNeeded()
        }
    }
    
    @IBAction func closeEventViewTapped(_ sender: Any) {
        showEventView(false)
    }

    @IBAction func calendarTapped(_ sender: Any) {
        showLeftView()
    }
    
    @IBAction func todayTapped(_ sender: Any) {
        calendar.scrollTo(Date())
    }
    
    @IBAction func modeTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: "Select calendar mode", preferredStyle: .actionSheet)
        
        var modes: [CalendarType] = [.day, .week, .month]
        
        if let index = modes.firstIndex(where: {$0 == mode}) {
            modes.remove(at: index)
        }
        
        for item in modes {
            let action = UIAlertAction(title: item.rawValue, style: .default) { (_) in
                self.mode = item
            }
            ac.addAction(action)
        }
        
        let popover = ac.popoverPresentationController
        popover?.sourceView = sender
        popover?.sourceRect = CGRect(x: -15, y: -30, width: 64, height: 64)

        present(ac, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        var previousDay: Date?
        var dateComponent    = DateComponents()
        switch mode {
        case .day:
            dateComponent.day = -1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        case .week:
            dateComponent.weekOfYear = -1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        case .month:
            dateComponent.month = -1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        default:
            break
        }
        calendar.scrollTo(previousDay ?? Date())
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        var previousDay: Date?
        var dateComponent    = DateComponents()
        switch mode {
        case .day:
            dateComponent.day = 1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        case .week:
            dateComponent.weekOfYear = 1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        case .month:
            dateComponent.month = 1
            previousDay = Calendar.current.date(byAdding: dateComponent, to: selectDate)
        default:
            break
        }
        calendar.scrollTo(previousDay ?? Date())
    }
}

extension CalendarViewController: CalendarDelegate {
    func didChangeEvent(_ event: Event, start: Date?, end: Date?) {
        var eventTemp = event
        guard let startTemp = start, let endTemp = end else { return }
        
        let startTime = timeFormatter(date: startTemp)
        let endTime = timeFormatter(date: endTemp)
        eventTemp.start = startTemp
        eventTemp.end = endTemp
        eventTemp.text = "\(startTime) - \(endTime)\n new time"
        
        if let idx = events.firstIndex(where: { $0.compare(eventTemp) }) {
            events.remove(at: idx)
            events.append(eventTemp)
            calendar.reloadData()
        }
    }
    
    func didAddEvent(_ date: Date?) {
        print(date)
    }
    
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
        selectDate = date ?? Date()
        calendar.reloadData()
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        print(type, event)
        showEventView(true)
    }
    
    func didSelectMore(_ date: Date, frame: CGRect?) {
        print(date)
    }
    
}

extension CalendarViewController: CalendarDataSource {
    func eventsForCalendar() -> [Event] {
        return events
    }
    
    private var dates: [Date] {
        return Array(0...10).compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: Date()) })
    }
    
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        guard dates.first(where: { $0.year == date?.year && $0.month == date?.month && $0.day == date?.day }) != nil else { return nil }
        
        return DateStyle(backgroundColor: .orange, textColor: .black, dotBackgroundColor: .red)
    }
}

extension CalendarViewController {
    func loadEvents(completion: ([Event]) -> Void) {
        var events = [Event]()
        let decoder = JSONDecoder()
                
        guard let path = Bundle.main.path(forResource: "events", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let result = try? decoder.decode(ItemData.self, from: data) else { return }
        
        for (idx, item) in result.data.enumerated() {
            let startDate = self.formatter(date: item.start)
            let endDate = self.formatter(date: item.end)
            let startTime = self.timeFormatter(date: startDate)
            let endTime = self.timeFormatter(date: endDate)
            
            var event = Event()
            event.id = idx
            event.start = startDate
            event.end = endDate
            event.color = EventColor(item.color)
            event.isAllDay = item.allDay
            event.isContainsFile = !item.files.isEmpty
            event.textForMonth = item.title
            
            if item.allDay {
                event.text = "\(item.title)"
            } else {
                event.text = "\(startTime) - \(endTime)\n\(item.title)"
            }
            events.append(event)
        }
        completion(events)
    }
    
    func timeFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.timeHourSystem == .twelveHour ? "h:mm a" : "HH:mm"
        return formatter.string(from: date)
    }
    
    func formatter(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: date) ?? Date()
    }
}
