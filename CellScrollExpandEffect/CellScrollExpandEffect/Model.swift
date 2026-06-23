import Foundation

struct SettingsItem: Identifiable, Hashable {
    let title: String
    let subtitle: String
    let systemImageName: String

    var id: String { title }
}

enum SettingsData {
    static let items: [SettingsItem] = [
        SettingsItem(
            title: "Thông tin tài khoản",
            subtitle: "Cập nhật họ tên, email và số điện thoại liên hệ.",
            systemImageName: "person.circle"
        ),
        SettingsItem(
            title: "Đổi mật khẩu",
            subtitle: "Thay đổi mật khẩu đăng nhập và thiết lập mật khẩu mạnh hơn.",
            systemImageName: "key"
        ),
        SettingsItem(
            title: "Xác thực hai lớp",
            subtitle: "Bật OTP qua SMS hoặc ứng dụng xác thực để bảo vệ tài khoản.",
            systemImageName: "lock.shield"
        ),
        SettingsItem(
            title: "Sinh trắc học",
            subtitle: "Đăng nhập nhanh bằng Face ID hoặc Touch ID trên thiết bị này.",
            systemImageName: "faceid"
        ),
        SettingsItem(
            title: "Quản lý thiết bị",
            subtitle: "Xem danh sách thiết bị đã đăng nhập và đăng xuất từ xa.",
            systemImageName: "iphone.and.arrow.forward"
        ),
        SettingsItem(
            title: "Thông báo đẩy",
            subtitle: "Nhận cảnh báo giao dịch, tin nhắn và cập nhật quan trọng.",
            systemImageName: "bell.badge"
        ),
        SettingsItem(
            title: "Email thông báo",
            subtitle: "Tuỳ chọn nhận bản tin, hóa đơn và thông báo bảo mật qua email.",
            systemImageName: "envelope"
        ),
        SettingsItem(
            title: "Quyền riêng tư",
            subtitle: "Kiểm soát dữ liệu cá nhân được thu thập và chia sẻ.",
            systemImageName: "hand.raised"
        ),
        SettingsItem(
            title: "Cookie & theo dõi",
            subtitle: "Quản lý cookie, phân tích hành vi và quảng cáo cá nhân hoá.",
            systemImageName: "eye.slash"
        ),
        SettingsItem(
            title: "Lịch sử đăng nhập",
            subtitle: "Theo dõi thời gian, vị trí và thiết bị truy cập gần đây.",
            systemImageName: "list.bullet.rectangle"
        ),
        SettingsItem(
            title: "Giao diện",
            subtitle: "Chọn chế độ sáng, tối hoặc theo cài đặt hệ thống.",
            systemImageName: "paintbrush"
        ),
        SettingsItem(
            title: "Ngôn ngữ",
            subtitle: "Chọn ngôn ngữ hiển thị: Tiếng Việt hoặc English.",
            systemImageName: "globe"
        ),
        SettingsItem(
            title: "Cỡ chữ",
            subtitle: "Điều chỉnh kích thước chữ trong toàn bộ ứng dụng.",
            systemImageName: "textformat.size"
        ),
        SettingsItem(
            title: "Âm thanh & rung",
            subtitle: "Bật hoặc tắt âm thanh thao tác và phản hồi rung.",
            systemImageName: "speaker.wave.2"
        ),
        SettingsItem(
            title: "Tiết kiệm dữ liệu",
            subtitle: "Giảm tải hình ảnh và video khi dùng mạng di động.",
            systemImageName: "antenna.radiowaves.left.and.right"
        ),
        SettingsItem(
            title: "Trung tâm trợ giúp",
            subtitle: "Câu hỏi thường gặp, hướng dẫn sử dụng và liên hệ hỗ trợ.",
            systemImageName: "questionmark.circle"
        ),
        SettingsItem(
            title: "Phản hồi ứng dụng",
            subtitle: "Gửi góp ý, báo lỗi hoặc đề xuất cải thiện trải nghiệm.",
            systemImageName: "text.bubble"
        ),
        SettingsItem(
            title: "Điều khoản sử dụng",
            subtitle: "Đọc điều khoản dịch vụ và quy định sử dụng ứng dụng.",
            systemImageName: "doc.text"
        ),
        SettingsItem(
            title: "Chính sách bảo mật",
            subtitle: "Tìm hiểu cách chúng tôi bảo vệ và xử lý dữ liệu của bạn.",
            systemImageName: "lock.doc"
        ),
        SettingsItem(
            title: "Phiên bản ứng dụng",
            subtitle: "CellScrollExpandEffect 1.0 — build demo hiệu ứng scroll.",
            systemImageName: "info.circle"
        ),
        SettingsItem(
            title: "Xoá bộ nhớ đệm",
            subtitle: "Giải phóng dung lượng bằng cách xoá file tạm và dữ liệu cache.",
            systemImageName: "trash"
        ),
        SettingsItem(
            title: "Đồng bộ dữ liệu",
            subtitle: "Đồng bộ cài đặt và tuỳ chọn giữa các thiết bị đã đăng nhập.",
            systemImageName: "arrow.triangle.2.circlepath"
        ),
        SettingsItem(
            title: "Đăng xuất",
            subtitle: "Thoát khỏi tài khoản hiện tại trên thiết bị này.",
            systemImageName: "rectangle.portrait.and.arrow.right"
        ),
    ]

    static let sections: [[SettingsItem]] = [
        Array(items[0..<5]),
        Array(items[5..<10]),
        Array(items[10..<15]),
        Array(items[15..<20]),
        Array(items[20..<items.count]),
    ]

    static func rowID(section: Int, item: Int) -> String {
        "\(section)-\(item)"
    }
}
