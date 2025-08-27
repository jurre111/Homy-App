import SwiftUI

struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "car"
    var stepOpacity: Double = 1.0

    var body: some View {
        HStack(alignment: .center) {
            VStack() {
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .padding()
                    .accessibility(hidden: true)
            }
            .frame(width: 40, height: 40, alignment: .center)
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