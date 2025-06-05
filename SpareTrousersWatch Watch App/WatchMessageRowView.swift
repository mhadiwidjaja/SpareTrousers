//
//  WatchMessageRowView.swift
//  SpareTrousers
//
//  Created by student on 05/06/25.
//


import SwiftUI

struct WatchMessageRowView: View {
    let message: InboxMessage

    private var displayTimestamp: String {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateStyle = .none
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.timeStyle = .none
        }
        return formatter.string(from: date)
    }

    var body: some View {
        HStack {
            if !message.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(message.dateLine)
                    .font(.system(size: 14, weight: message.isRead ? .regular : .semibold))
                    .lineLimit(2)

                if let itemName = message.itemName, !itemName.isEmpty {
                    Text("Item: \(itemName)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if let otherParty = message.lenderName, !otherParty.isEmpty {
                    Text("From: \(otherParty)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text(displayTimestamp)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
