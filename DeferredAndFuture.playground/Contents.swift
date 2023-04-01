
import Combine


private var cancellables = Set<AnyCancellable>()

func fetchName (comletionHandler: (Result<String, Error>) -> Void )  {
   
   // Fancy API code
    let name = "Insert name here"
    comletionHandler(.success(name))
}

func name() -> AnyPublisher<String, Error> {
    return Deferred {
        Future<String, Error> { promise in
            fetchName { result in
                switch result {
                case .success(let name):
                    promise(.success(name))
                case .failure(let err):
                    promise(.failure(err))
                }
            }
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



