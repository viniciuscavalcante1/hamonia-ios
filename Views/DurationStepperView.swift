// Views/DurationStepperView.swift

import SwiftUI

struct DurationStepperView: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .frame(width: 70, alignment: .leading)
            
            Text("\(value)")
                .font(.title2.monospacedDigit())
                .fontWeight(.semibold)
                .frame(width: 50)

            Stepper(label, value: $value, in: range, step: step)
                .labelsHidden()
        }
    }
}
