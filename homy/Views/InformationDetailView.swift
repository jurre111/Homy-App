import SwiftUI

struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "car"
    var stepOpacity: Double = 1.0
    var imageWidth: CGFloat = 50 // fixed width for all images

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: imageName)
                .resizable()               // allows scaling
                .scaledToFit()             // keeps aspect ratio
                .frame(width: imageWidth)  // fixed width
                .foregroundColor(Color(UIColor.systemBlue))
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
