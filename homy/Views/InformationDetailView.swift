import SwiftUI

struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "car"
    var stepOpacity: Double = 1.0

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .resizable()
                .padding()
                .scaledToFit() // scales symbol while maintaining aspect ratio
                .frame(width: 40, height: 40) // flexible, smaller than before
                .foregroundColor(Color(UIColor.systemBlue))
                .font(.largeTitle)
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .opacity(stepOpacity)
        .padding(.top)
    }
}