//
//  TastingEntryRow.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/23/26.
//

import SwiftUI

struct TastingEntryRow: View {
    let row: EntryRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if row.timeLabel != nil || row.rating != nil {
                HStack {
                    if let timeLabel = row.timeLabel {
                        Text(timeLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let rating = row.rating {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(rating.tens)
                            Image(systemName: "star.fill")
                                .imageScale(.small)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                } //: HStack
            }

            Text(row.note)
        } //: VStack
    }
}
