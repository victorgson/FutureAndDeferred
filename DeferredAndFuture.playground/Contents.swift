
import Combine
import Foundation
import UIKit

private var cancellables = Set<AnyCancellable>()

struct User: Codable {
    let name: String
}

func fetchName() -> AnyPublisher<[User], Error>  {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

    return Deferred {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    .eraseToAnyPublisher()
}

func name() -> AnyPublisher<String, Error> {
    return Deferred {
        Future<String, Error> { promise in
            fetchName().sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { users in
                if let firstUser = users.first {
                    promise(.success(firstUser.name))
                } else {
                    promise(.failure(NSError(domain: "No user found", code: 0, userInfo: nil)))
                }
            }).store(in: &cancellables)
        }
    }.eraseToAnyPublisher()
}
name().sink { completion in
    switch completion {
    case .finished:
        print("Finished")
        break
    case .failure(let err):
        print(err)
        break
    }
} receiveValue: { name in
    print(name)
}.store(in: &cancellables)



