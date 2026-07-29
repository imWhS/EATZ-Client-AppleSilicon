//
//  CalendarPickerCell.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/25.
//

import SwiftUI
import FSCalendar

class CalendarCell: FSCalendarCell {
    private weak var selectionFillLayer: CAShapeLayer!
    private weak var borderLayer: CAShapeLayer!
    private weak var todayLayer: CAShapeLayer!
    
    var isDisabled: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        // 셀 디자인 커스터마이징을 위해 FSCalendarCell의 기본 레이어를 숨김 처리합니다.
        self.shapeLayer.isHidden = true
        
        // 오늘 날짜에 해당하는 셀에 사용될 뷰를 정의합니다.
        let todayLayer = CAShapeLayer()
//        todayLayer.fillColor = UIColor.init(hex: "BFD8DA").withAlphaComponent(1).cgColor
//        todayLayer.strokeColor = UIColor.init(hex: "BFD8DA").withAlphaComponent(1).cgColor
        todayLayer.fillColor = UIColor.clear.cgColor
        todayLayer.strokeColor = Color.black.opacity(0.075).cgColor
        todayLayer.isHidden = true
        self.contentView.layer.insertSublayer(todayLayer, at: 0)
        self.todayLayer = todayLayer
        
        // 선택할 수 있는 셀(선택되지 않은 셀)에 사용될 뷰를 정의합니다.
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = Color.init(hex: "ECECEC").cgColor
        borderLayer.lineWidth = 1.0
        borderLayer.isHidden = true
        self.contentView.layer.insertSublayer(borderLayer, below: self.titleLabel.layer)
        self.borderLayer = borderLayer

        // 선택된 셀에 사용될 뷰를 정의합니다.
        let selectionFillLayer = CAShapeLayer()
        selectionFillLayer.fillColor = UIColor.init(hex: "00BECA").withAlphaComponent(1).cgColor
        selectionFillLayer.isHidden = true
        self.contentView.layer.insertSublayer(selectionFillLayer, above: self.borderLayer)
        self.selectionFillLayer = selectionFillLayer
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.todayLayer.frame = self.contentView.bounds
        self.selectionFillLayer.frame = self.contentView.bounds
        self.borderLayer.frame = self.contentView.bounds
        
        let diameter: CGFloat = 42.0
        let path = UIBezierPath(ovalIn: CGRect(
            x: self.contentView.bounds.width / 2 - diameter / 2,
            y: self.contentView.bounds.height / 2 - diameter / 2,
            width: diameter,
            height: diameter
        )).cgPath
        
        self.todayLayer.path = path
        self.selectionFillLayer.path = path
        self.borderLayer.path = path
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 셀이 재사용되기 전에 모든 custom 레이어 및 프로퍼티의 값을 초기화합니다.
        selectionFillLayer.isHidden = true
        borderLayer.isHidden = true
        todayLayer.isHidden = true
        
        isDisabled = false
        
        transform = .identity
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        selectionFillLayer.isHidden = true
        borderLayer.isHidden = true
        todayLayer.isHidden = true
        
        if isDisabled {
            // 1. 비활성화된 날짜 (가장 높은 우선 순위)
            titleLabel.textColor = .systemGray4
            return // 비활성화 상태이므로 여기서 스타일링을 종료합니다.
        }
        
        if isSelected {
            // 2순위: 선택된 날짜
            selectionFillLayer.isHidden = false
            titleLabel.textColor = .white
            return
        }
        
        if dateIsToday {
            // 3순위: 오늘 날짜 (선택되지 않음)
            todayLayer.isHidden = false
            titleLabel.textColor = .init(hex: "00BECA")
        } else if isPlaceholder {
            // 4순위: 이전/다음 달의 날짜
            borderLayer.isHidden = false
            titleLabel.textColor = .lightGray
        } else {
            // 5순위: 그 외 모든 일반 날짜
            borderLayer.isHidden = false
            titleLabel.textColor = .black
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isDisabled { return }
        
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
}
