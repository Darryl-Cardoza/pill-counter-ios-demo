//
//  PillCountingCalendar.swift
//  PillCounter
//
//  Created by HC on 06/11/25.
//

import SwiftUI

struct PillCountingCalendar: View {
    
    @EnvironmentObject private var appColors: AppColors
    @Environment(\.isLandscape) private var isLandscape
    
    let selectedColor: Color
    let textColor: Color
    let backgroundColor: Color
    
    @Binding var selectedDate: Date
    @State private var monthsToShow: [Date] = []
    
    private let calendar = Calendar.current
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(monthsToShow, id: \.self) { month in
                    VStack(alignment: .leading, spacing: 10) {
                        
                        // Month Header
                        Text(monthYearString(for: month))
                            .font(.title3.bold())
                            .foregroundColor(textColor)
                        
                        // Weekday Row
                        HStack {
                            ForEach(days.indices, id: \.self) { index in
                                Text(days[index])
                                    .font(.caption)
                                    .foregroundColor(textColor.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Grid of days
                        let daysInMonth = getDaysInMonth(for: month)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 6) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                                if let date = date {
                                    dayButton(for: date)
                                } else {
                                    Color.clear.frame(height: 32)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .defaultScrollAnchor(.bottom)
        .onAppear { initializeMonths() }
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private func dayButton(for date: Date) -> some View {
        Button {
            if !isFuture(date) {
                selectedDate = date
            }
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .foregroundColor(textColorFor(date))
                .frame(width: 32, height: 32)
                .background(backgroundColorFor(date))
                .clipShape(Circle())
                .opacity(isFuture(date) ? 0.3 : 1)
        }
        .disabled(isFuture(date))
    }
    
    // MARK: - Helpers
    
    private func initializeMonths() {
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        monthsToShow = (0...12).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonth)
        }.reversed()
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func getDaysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(dayDate)
            }
        }
        return days
    }
    
    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }
    
    private func isFuture(_ date: Date) -> Bool {
        date > Date()
    }
    
    private func backgroundColorFor(_ date: Date) -> Color {
        if isSameDay(date, selectedDate) {
            return selectedColor
        }
        if isSameDay(date, Date()) {
            return selectedColor.opacity(0.4)
        }
        return .clear
    }
    
    private func textColorFor(_ date: Date) -> Color {
        isSameDay(date, selectedDate) ? Color.white : textColor
    }
}
