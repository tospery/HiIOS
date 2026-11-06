import DeviceKit
import Foundation

/// 向调用方提供稳定描述，不把 DeviceKit 的枚举放进公开 API。
public struct IOSDeviceDescriptor: Equatable, Sendable {
    public let modelName: String
    public let isSimulator: Bool

    public init(modelName: String, isSimulator: Bool) {
        self.modelName = modelName
        self.isSimulator = isSimulator
    }

    @MainActor
    public static func current() -> IOSDeviceDescriptor {
        let device = Device.current
        return IOSDeviceDescriptor(
            modelName: device.safeDescription,
            isSimulator: device.isSimulator
        )
    }
}
