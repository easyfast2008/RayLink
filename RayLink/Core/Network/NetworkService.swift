import Foundation
import Combine
import Network

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    func downloadConfig(from url: URL) async throws -> Data
    var networkStatus: AnyPublisher<NetworkStatus, Never> { get }
}

// MARK: - Network Status
enum NetworkStatus {
    case connected
    case disconnected
    case connecting
}

// MARK: - API Endpoint
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    
    init(path: String, method: HTTPMethod = .GET, headers: [String: String]? = nil, body: Data? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkUnavailable:
            return "Network unavailable"
        case .timeout:
            return "Request timeout"
        case .unknown:
            return "Unknown network error"
        }
    }
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol, ObservableObject {
    private let session: URLSession
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let networkStatusSubject = CurrentValueSubject<NetworkStatus, Never>(.disconnected)
    
    var networkStatus: AnyPublisher<NetworkStatus, Never> {
        networkStatusSubject.eraseToAnyPublisher()
    }
    
    init(session: URLSession = .shared) {
        self.session = session
        startNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.networkStatusSubject.send(.connected)
                } else {
                    self?.networkStatusSubject.send(.disconnected)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = URL(string: endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("RayLink/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            } else {
                throw NetworkError.unknown
            }
        }
    }
    
    func downloadConfig(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown
        }
    }
}