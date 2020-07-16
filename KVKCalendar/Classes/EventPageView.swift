//
//  EventPageView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

private let pointX: CGFloat = 5

final class EventPageView: UIView {
    weak var delegate: EventPageDelegate?
    let event: Event
    private let timelineStyle: TimelineStyle
    private let color: UIColor
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.backgroundColor = .red
        return imv
    }()
    
    init(event: Event, style: Style, frame: CGRect) {
        self.event = event
        self.timelineStyle = style.timeline
        self.color = EventColor(event.color?.value ?? event.backgroundColor).value
        super.init(frame: frame)
        backgroundColor = event.backgroundColor
        
        updateLayout(frame)
        
        tag = "\(event.id)".hashValue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnEvent))
        addGestureRecognizer(tap)
        
        if style.event.isEnableMoveEvent {
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(activateMoveEvent))
            longGesture.minimumPressDuration = style.event.minimumPressDuration
            addGestureRecognizer(longGesture)
        }
    }
    
    private func updateLayout(_ frame: CGRect) {
        
        var timeHeight: CGFloat = 15
        var nameHeight: CGFloat = 15
        let avatarSize: CGFloat = 30
        
        if frame.height >= 80 {
            if frame.width >= 100 {
                // Nothing to change
            } else if frame.width >= 40 {
                if frame.height >= 110 {
                    timeHeight = 30
                    nameHeight = 30
                }
            } else {
                return
            }
            
            timeLabel.frame = CGRect(x: pointX, y: pointX, width: frame.width - pointX * 2, height: timeHeight)
            timeLabel.text = "time1 - time2"
            addSubview(timeLabel)
            
            avatarImageView.frame = CGRect(x: pointX, y: pointX * 2 + timeLabel.frame.height, width: avatarSize, height: avatarSize)
            avatarImageView.layer.cornerRadius = avatarSize / 2
            avatarImageView.clipsToBounds = true
            addSubview(avatarImageView)
            
            nameLabel.frame = CGRect(x: pointX, y: pointX + avatarImageView.frame.origin.y + avatarImageView.frame.height, width: frame.width - pointX * 2, height: nameHeight)
            nameLabel.text = "contributor name"
            addSubview(nameLabel)
        } else if frame.height >= 40 {
            
            avatarImageView.frame = CGRect(x: pointX, y: (frame.height - avatarSize)/2, width: avatarSize, height: avatarSize)
            avatarImageView.layer.cornerRadius = avatarSize / 2
            avatarImageView.clipsToBounds = true
            addSubview(avatarImageView)
            
            timeLabel.frame = CGRect(x: pointX * 2 + avatarSize, y: (frame.height - avatarSize - pointX)/2, width: frame.width - pointX *  3 - avatarSize, height: timeHeight)
            timeLabel.text = "time1 - time2"
            addSubview(timeLabel)
            
            nameLabel.frame = CGRect(x: pointX * 2 + avatarSize, y: pointX + timeLabel.frame.origin.y + timeLabel.frame.height, width: frame.width - pointX *  3 - avatarSize, height: nameHeight)
            nameLabel.text = "contributor name"
            addSubview(nameLabel)
        } else {
            timeLabel.frame = CGRect(x: pointX, y: pointX, width: frame.width - pointX * 2, height: timeHeight)
            timeLabel.text = "time1 - time2"
            addSubview(timeLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapOnEvent(gesture: UITapGestureRecognizer) {
        delegate?.didSelectEvent(event, gesture: gesture)
    }
    
    @objc private func activateMoveEvent(gesture: UILongPressGestureRecognizer) {        
        switch gesture.state {
        case .began:
            delegate?.didStartMoveEventPage(self, gesture: gesture)
        case .changed:
            delegate?.didChangeMoveEventPage(self, gesture: gesture)
        case .cancelled, .ended, .failed:
            delegate?.didEndMoveEventPage(self, gesture: gesture)
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.interpolationQuality = .none
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        let x: CGFloat = 1
        let y: CGFloat = 0
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: bounds.height))
        context.strokePath()
        context.restoreGState()
    }
}

protocol EventPageDelegate: class {
    func didStartMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didEndMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didChangeMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didSelectEvent(_ event: Event, gesture: UITapGestureRecognizer)
}
