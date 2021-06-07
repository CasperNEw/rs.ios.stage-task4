import Foundation

final class CallStation {

    // MARK: - Properties
    private var connectedUsers: Set<User> = []
    private var currentCalls: Set<Call> = []
}

// MARK: - Station
extension CallStation: Station {

    func users() -> [User] {
        Array(connectedUsers)
    }
    
    func add(user: User) {
        connectedUsers.insert(user)
    }
    
    func remove(user: User) {
        if let call = currentCalls.first(where: { $0.incomingUser == user || $0.outgoingUser == user }) {
            currentCalls.updateCall(call, with: .ended(reason: .error))
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
        case .start(let incoming, let outgoing):
            // Проверяем доступность совершения звонка
            guard connectedUsers.contains(incoming) else { return nil }
            guard connectedUsers.contains(outgoing)
            else {
                return currentCalls.insertCall(incoming: incoming, outgoing: outgoing, status: .ended(reason: .error))
            }
            guard currentCalls.filter({ !$0.availabilityOf(users: [incoming, outgoing])}).isEmpty
            else {
                return currentCalls.insertCall(incoming: incoming, outgoing: outgoing, status: .ended(reason: .userBusy))
            }
            // Запускаем звонок
            return currentCalls.insertCall(incoming: incoming, outgoing: outgoing, status: .calling)

        case .answer(let outgoingUser):
            // Проверяем наличие доступных звонков для ответа
            guard let call = currentCalls.first(where: { $0.outgoingUser == outgoingUser }),
                  call.status == .calling
            else { return nil }
            // Обновляем информацию о звонке
            return currentCalls.updateCall(call, with: .talk)

        case .end(let user):
            // Проверяем наличие текущего звонка для пользователя
            guard let call = currentCalls.first(where: { $0.incomingUser == user || $0.outgoingUser == user}),
                  let reason = call.status.endReason
            else { return nil }
            // Обновляем информацию о звонке
            return currentCalls.updateCall(call, with: .ended(reason: reason))
        }
    }
    
    func calls() -> [Call] {
        Array(currentCalls)
    }
    
    func calls(user: User) -> [Call] {
        currentCalls.filter({ ($0.incomingUser == user || $0.outgoingUser == user) })
    }
    
    func call(id: CallID) -> Call? {
        currentCalls.first(where: { $0.id == id })
    }
    
    func currentCall(user: User) -> Call? {
        currentCalls.first(where: { ($0.incomingUser == user || $0.outgoingUser == user) &&
                            ($0.status == .calling || $0.status == .talk) })
    }
}

// MARK: - ext Call
extension Call {

    func availabilityOf(users: [User]) -> Bool {
        users.filter({ $0 == incomingUser || $0 == outgoingUser }).isEmpty
    }

    init(incoming: User, outgoing: User, status: CallStatus) {
        self.id = CallID()
        self.incomingUser = incoming
        self.outgoingUser = outgoing
        self.status = status
    }

    init(call: Call, status: CallStatus) {
        self.id = call.id
        self.incomingUser = call.incomingUser
        self.outgoingUser = call.outgoingUser
        self.status = status
    }
}

extension Call: Hashable {

    static func == (lhs: Call, rhs: Call) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
}

// MARK: - ext CallStatus
extension CallStatus {

    var endReason: CallEndReason? {
        if self == .calling { return .cancel }
        if self == .talk { return .end }
        return nil
    }
}

// MARK: - ext User
extension User: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
}

// MARK: - ext Set<Call>
extension Set where Element == Call {

    mutating func insertCall(incoming: User, outgoing: User, status: CallStatus) -> CallID {
        let call = Call(incoming: incoming, outgoing: outgoing, status: status)
        insert(call)
        return call.id
    }

    @discardableResult
    mutating func updateCall(_ call: Call, with status: CallStatus) -> CallID {
        update(with: Call(call: call, status: status))
        return call.id
    }
}
