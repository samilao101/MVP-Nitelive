//
//  TimeStampView.swift
//  Nitelive
//
//  Created by Sam Santos on 6/16/22.
//

import SwiftUI

struct TimeStampView: View {
    
    let date : Date
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    init(date: Date) {
        self.date = date
    }
    
    var body: some View {
  
        Text(dateFormatter.string(from: date))
            .font(.headline)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
                    .foregroundColor(.white)
                    
            )

    }
}

struct TimeStampView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStampView(date: Date())
    }
}
