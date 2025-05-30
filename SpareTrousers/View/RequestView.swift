//
//  RequestView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//
import SwiftUI

struct RequestView: View {
    // The item being requested
    let item: DisplayItem

    // State for selected dates
    @State private var startDate = Date()
    @State private var endDate = Date() // Initialize to a day after start date or similar logic
    @Environment(\.presentationMode) var presentationMode

    // Date range: allow selection from today onwards
    var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let distantFuture = Calendar.current.date(byAdding: .year, value: 5, to: today)!
        return today...distantFuture
    }
    
    // Formatter for the month/year display
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Header Text
                Text("Borrow Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                // Item Information
                HStack(spacing: 15) {
                    Image(item.imageName) // Ensure this image exists in assets
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .clipped()
                        // Fallback if image is not found
                        .overlay {
                            if UIImage(named: item.imageName) == nil {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(Text("No\nImage").font(.caption).multilineTextAlignment(.center))
                            }
                        }


                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        Text(item.rentalPrice)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer() // Pushes content to the left
                }
                .padding(.horizontal)

                Divider()

                // Start Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Start Date")
                        .font(.headline)
                    
                    // Custom Date Picker Header
                    HStack {
                        Text(monthYearFormatter.string(from: startDate))
                            .font(.title3).bold()
                        Spacer()
                        Button(action: {
                            // Action to go to previous month (if implementing custom controls)
                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate) {
                                startDate = newDate
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        Button(action: {
                             // Action to go to next month (if implementing custom controls)
                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) {
                                startDate = newDate
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal, 5)


                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle()) // Shows the calendar view
                    .labelsHidden() // Hide the default "Start Date" label as we have a custom one
                }
                .padding(.horizontal)

                Divider()

                // End Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select End Date")
                        .font(.headline)

                    HStack {
                        Text(monthYearFormatter.string(from: endDate))
                            .font(.title3).bold()
                        Spacer()
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) {
                                endDate = newDate
                            }
                        }) { Image(systemName: "chevron.left") }
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: endDate) {
                                endDate = newDate
                            }
                        }) { Image(systemName: "chevron.right") }
                    }
                     .padding(.horizontal, 5)

                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        // Ensure end date is after start date
                        in: max(startDate, dateRange.lowerBound)...dateRange.upperBound,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30) // Space before the button

                // Send Request Button
                Button(action: {
                    // Action to send the borrow request
                    print("Send Request Tapped!")
                    print("Item: \(item.name)")
                    print("Start Date: \(startDate)")
                    print("End Date: \(endDate)")
                    // Potentially dismiss this view or navigate further
                    // presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Send Request")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange) // Match image
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20) // Padding at the very bottom
            }
        }
        .navigationTitle("Borrow Details") // Sets the title in the navigation bar
        .navigationBarTitleDisplayMode(.inline)
        // .navigationBarBackButtonHidden(false) // Ensure back button is visible
    }
}

// MARK: - Preview
//struct RequestView_Previews: PreviewProvider {
//    static var sampleItem = DisplayItem(id: "123", name: "Orange and Blue Trousers", imageName: "DummyProduct", rentalPrice: "Rp 20.000 /day", categoryId: 1)
//
//    static var previews: some View {
//        NavigationView {
//            RequestView(item: sampleItem)
//        }
//        .preferredColorScheme(.light)
//
//        NavigationView {
//            RequestView(item: sampleItem)
//        }
//        .preferredColorScheme(.dark)
//    }
//}
