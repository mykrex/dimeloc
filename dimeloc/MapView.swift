import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), // Monterrey
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        var body: some View {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)
        }
}



#Preview {
    MapView()
}
