import SwiftUI

struct HomeView: View {
    // MARK: - App colors matching FeedbackListView
    private let aiGradientStart = Color(red: 0.408, green: 0.541, blue: 0.914) // #688AE9
    private let aiGradientEnd = Color(red: 0.776, green: 0.427, blue: 0.482) // #C66D7B
    private let softBlue = Color(red: 0.635, green: 0.824, blue: 1.0) // #A2D2FF
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    
    // MARK: - Authentication Manager
    @EnvironmentObject private var authManager: AuthManager
    
    // MARK: - Logout State
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    
    // MARK: - Calendar State
    @State private var selectedCalendarFilter: CalendarFilter = .month
    @State private var selectedDate = Date()
    
    enum CalendarFilter: String, CaseIterable {
        case day = "Día"
        case week = "Semana"
        case month = "Mes"
    }

    // MARK: - Updated Mock data models with image parameter
    struct PendingVisit: Identifiable {
        let id = UUID()
        let storeName: String
        let visitDate: Date
        let image: String // 👈 Nuevo parámetro
    }
    
    struct PendingStore: Identifiable {
        let id = UUID()
        let storeName: String
        let image: String // 👈 Nuevo parámetro
    }

    // MARK: - Updated example mock data with images
    var pendingVisits: [PendingVisit] = [
        PendingVisit(
            storeName: "Oxxo Junco de la Vega",
            visitDate: DateComponents(calendar: .current, year: 2025, month: 6, day: 25).date!,
            image: "oxxo"
        ),
        PendingVisit(
            storeName: "Modelorama Rio Nazas",
            visitDate: DateComponents(calendar: .current, year: 2025, month: 7, day: 2).date!,
            image: "modelorama"
        ),
        PendingVisit(
            storeName: "OXXO Colima II",
            visitDate: DateComponents(calendar: .current, year: 2025, month: 7, day: 9).date!,
            image: "oxxo"
        )
    ]
    
    var pendingStores: [PendingStore] = [
        PendingStore(
            storeName: "H-E-B Valle Oriente",
            image: "heb"
        ),
        PendingStore(
            storeName: "Walmart las Torres",
            image: "walmart"
        ),
        PendingStore(
            storeName: "7-Eleven Benito Juarez",
            image: "7eleven"
        )
    ]

    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Sleek Header
                HStack {
                    // Show user info if available
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hola, \(user.nombre)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Dashboard")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // MARK: - Enhanced Gemini Insights Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header with gradient elements
                    HStack(alignment: .top, spacing: 12) {
                        // Gradient lightbulb icon
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [aiGradientStart, aiGradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let user = authManager.currentUser {
                                // Gradient title
                                Text("Gemini Insights")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [aiGradientStart, aiGradientEnd],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                // 👈 Updated text with bold store name
                                Text(attributedInsightText(for: user.nombre))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [aiGradientStart.opacity(0.3), aiGradientEnd.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .padding(.horizontal, 20)

                // MARK: - Calendar Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Calendario")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Calendar filter menu
                        Menu {
                            ForEach(CalendarFilter.allCases, id: \.self) { filter in
                                Button(filter.rawValue) {
                                    selectedCalendarFilter = filter
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedCalendarFilter.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    
                    // Calendar View
                    CalendarGridView(
                        selectedDate: $selectedDate,
                        filter: selectedCalendarFilter,
                        pendingVisits: pendingVisits
                    )
                }
                .padding(.horizontal, 20)

                // MARK: - Pending Visits Section with custom images and navigation
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Visitas pendientes:")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(pendingVisits.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(accentColor)
                                    .shadow(color: accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(pendingVisits) { visit in
                            Button(action: {
                                // TODO: Navigate to TiendaDetailView - you'll add the parameters later
                                print("Navigate to TiendaDetailView for: \(visit.storeName)")
                            }) {
                                HStack(spacing: 12) {
                                    // Store icon with custom image
                                    ZStack {
                                        if visit.image.isEmpty {
                                            Circle()
                                                .fill(Color(.systemGray6))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Image(systemName: "storefront")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                )
                                        } else {
                                            Image(visit.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                                )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(visit.storeName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text(dateFormatter.string(from: visit.visitDate))
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status indicator + Navigation arrow
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(softBlue.opacity(0.3))
                                            .frame(width: 8, height: 8)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 0.5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(.systemGray6).opacity(0.5), lineWidth: 0.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - Pending Stores Section with custom images and navigation
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Tiendas pendientes de visita")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(pendingStores.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(accentColor)
                                    .shadow(color: accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(pendingStores) { store in
                            Button(action: {
                                // TODO: Navigate to TiendaDetailView - you'll add the parameters later
                                print("Navigate to TiendaDetailView for: \(store.storeName)")
                            }) {
                                HStack(spacing: 12) {
                                    // Store icon with custom image
                                    ZStack {
                                        if store.image.isEmpty {
                                            Circle()
                                                .fill(Color(.systemGray6))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Image(systemName: "storefront")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                )
                                        } else {
                                            Image(store.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                                )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(store.storeName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Pendiente de primera visita")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status indicator + Navigation arrow
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.orange.opacity(0.3))
                                            .frame(width: 8, height: 8)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 0.5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(.systemGray6).opacity(0.5), lineWidth: 0.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - 🚪 LOGOUT SECTION
                VStack(spacing: 16) {
                    // Divider
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                    
                    // Logout button
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack(spacing: 12) {
                            if isLoggingOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            Text(isLoggingOut ? "Cerrando sesión..." : "Terminar Sesión")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.8), Color.red],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    }
                    .disabled(isLoggingOut)
                    .padding(.horizontal, 20)
                    
                    // User info section
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Sesión activa")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        if let user = authManager.currentUser {
                            HStack(spacing: 8) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(user.email)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Última actividad: ahora")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 24)
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert("Terminar Sesión", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar tu sesión?")
        }
    }
    
    // MARK: - Helper para texto con bold
    private func attributedInsightText(for userName: String) -> AttributedString {
        var attributedString = AttributedString("\(userName), tienes 1 visita pendiente este mes. Para tu siguiente visita con Oxxo Junco de la Vega, recomiendo priorizar el tema del refrigerador averiado y la optimizacion del inventario.")
        
        // Hacer bold "Oxxo Junco de la Vega"
        if let range = attributedString.range(of: "Oxxo Junco de la Vega") {
            attributedString[range].font = .system(size: 14, weight: .bold)
        }
        
        return attributedString
    }
    
    // MARK: - 🚪 LOGOUT FUNCTION (Fixed)
    private func performLogout() {
        isLoggingOut = true
        
        // Add a small delay for UX (optional)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Use the AuthManager's logout function
            authManager.logout()
            isLoggingOut = false
        }
    }
}

// MARK: - Calendar Grid View Component (sin cambios)
struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let filter: HomeView.CalendarFilter
    let pendingVisits: [HomeView.PendingVisit]
    
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    private let calendar = Calendar.current
    
    // Get dates for current filter
    private var displayDates: [Date] {
        switch filter {
        case .day:
            return [selectedDate]
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
            let range = calendar.range(of: .day, in: .month, for: selectedDate) ?? 1..<32
            return range.compactMap { day in
                calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
            }
        }
    }
    
    // Check if date has visits
    private func hasVisit(on date: Date) -> Bool {
        pendingVisits.contains { visit in
            calendar.isDate(visit.visitDate, inSameDayAs: date)
        }
    }
    
    // Get visits for specific date
    private func visits(for date: Date) -> [HomeView.PendingVisit] {
        pendingVisits.filter { visit in
            calendar.isDate(visit.visitDate, inSameDayAs: date)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Current date header with navigation
            HStack {
                if filter == .day {
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(headerText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if filter == .day {
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(displayDates, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasVisit: hasVisit(on: date),
                        visitCount: visits(for: date).count,
                        filter: filter
                    ) {
                        selectedDate = date
                    }
                }
            }
            
            // Selected day information
            SelectedDayInfoView(
                selectedDate: selectedDate,
                visits: visits(for: selectedDate)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemGray6).opacity(0.5), lineWidth: 0.5)
        )
    }
    
    private var headerText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        switch filter {
        case .day:
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: selectedDate).capitalized
        case .week:
            formatter.dateFormat = "d MMM"
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
            return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))".capitalized
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate).capitalized
        }
    }
    
    private var gridColumns: [GridItem] {
        switch filter {
        case .day:
            return [GridItem(.flexible())]
        case .week:
            return Array(repeating: GridItem(.flexible()), count: 7)
        case .month:
            return Array(repeating: GridItem(.flexible()), count: 7)
        }
    }
}

// MARK: - Selected Day Info View Component (sin cambios)
struct SelectedDayInfoView: View {
    let selectedDate: Date
    let visits: [HomeView.PendingVisit]
    
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(accentColor)
                
                Text(dateFormatter.string(from: selectedDate).capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Visits or no events message
            if visits.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("No hay eventos este día")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(visits) { visit in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 6, height: 6)
                            
                            Text("Visita a \(visit.storeName)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

// MARK: - Calendar Day Cell Component (sin cambios)
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasVisit: Bool
    let visitCount: Int
    let filter: HomeView.CalendarFilter
    let onTap: () -> Void
    
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Day number
                Text(dayText)
                    .font(.system(size: filter == .month ? 14 : 16, weight: .medium))
                    .foregroundColor(textColor)
                
                // Visit indicator
                if hasVisit {
                    if visitCount > 1 {
                        Text("\(visitCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(accentColor))
                    } else {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 6, height: 6)
                    }
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: cellWidth, height: cellHeight)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        switch filter {
        case .day:
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        case .week:
            formatter.dateFormat = "EEE\nd"
            return formatter.string(from: date).capitalized
        case .month:
            return "\(calendar.component(.day, from: date))"
        }
    }
    
    private var cellWidth: CGFloat {
        switch filter {
        case .day: return 80
        case .week: return 40
        case .month: return 35
        }
    }
    
    private var cellHeight: CGFloat {
        switch filter {
        case .day: return 60
        case .week: return 50
        case .month: return 40
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return accentColor.opacity(0.1)
        }
        return Color(.systemGray6).opacity(0.3)
    }
    
    private var borderColor: Color {
        if isSelected {
            return accentColor
        }
        return Color(.systemGray6)
    }
    
    private var textColor: Color {
        if isSelected {
            return accentColor
        }
        return .primary
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
            .previewDisplayName("Home with Logout")
    }
}
