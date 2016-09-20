//
//  RestGameService.swift
//  doodle-monster
//
//  Created by Josh Freed on 5/18/16.
//  Copyright © 2016 BleepSmazz. All rights reserved.
//

import UIKit
import Alamofire

class RestGameService: GameService {
    let apiUrl: String
    let session: SessionService
    let gameTranslator: RestGameTranslator
    
    init(apiUrl: String, session: SessionService, gameTranslator: RestGameTranslator) {
        self.apiUrl = apiUrl
        self.session = session
        self.gameTranslator = gameTranslator
    }
    
    func createGame(_ players: [Player], callback: @escaping (Result<Game>) -> ()) {
        let headers = [
            "Authorization": "Bearer " + session.token!,
        ]
        
        var playerIds: [String] = []
        for player in players {
            playerIds.append(player.id!)
        }
        let params = [
            "players": playerIds
        ]
        
        Alamofire
            .request(apiUrl + "/monsters", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                print(response.response)
                
                switch response.result {
                case .success(let json):
                    print(json)
                    guard let data = json as? NSDictionary else {
                        // successful http request; bad data from server
                        callback(.failure(DoodMonError.unexpectedResponse))
                        return
                    }
                    
                    let game = self.gameTranslator.dictionaryToModel(data)
                    callback(.success(game))
                    
                    break
                    
                case .failure(let error): callback(.failure(self.parseErrorType(error, data: response.data)))
                }
            }
    }
    
    func getActiveGames(_ callback: @escaping (Result<[Game]>) -> ()) {
        let headers = [
            "Authorization": "Bearer " + session.token!,
        ]
        Alamofire
            .request(apiUrl + "/me/monsters", headers: headers)
            .validate()
            .responseJSON { response in
                print(response.response)
                
                switch response.result {
                case .success(let json):
                    guard let objects = json as? [NSDictionary] else {
                        print(json)
                        return
                    }
                    
                    var games: [Game] = []
                    for object in objects {
                        games.append(self.gameTranslator.dictionaryToModel(object))
                    }
                    callback(.success(games))
                    
                case .failure(let error): callback(.failure(self.parseErrorType(error, data: response.data)))
                }
            }
    }
    
    func saveTurn(_ gameId: String, image: Data, letter: String, completion: @escaping (Result<Game>) -> ()) {
        let headers = [
            "Authorization": "Bearer " + session.token!,
        ]
        
        let url = apiUrl + "/monster/" + gameId + "/turns"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image, withName: "imageData", fileName: "monster_turn.png", mimeType: "image/png")
                multipartFormData.append(letter.data(using: String.Encoding.utf8)!, withName: "letter")
            },
            to: url,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload
                        .validate()
                        .responseJSON { response in
                            print(response.response)
                            
                            switch response.result {
                            case .success(let json):
                                print(json)
                                guard let data = json as? NSDictionary else {
                                    // successful http request; bad data from server
                                    completion(.failure(DoodMonError.unexpectedResponse))
                                    return
                                }
                                
                                let game = self.gameTranslator.dictionaryToModel(data)
                                completion(.success(game))
                                
                                break
                                
                            case .failure(let error): completion(.failure(self.parseErrorType(error, data: response.data)))
                            }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    func loadImageData(_ gameId: String, completion: @escaping (Result<Data>) -> ()) {
        let headers = [
            "Authorization": "Bearer " + session.token!,
        ]
        Alamofire
            .request(apiUrl + "/monster/" + gameId, headers: headers)
            .validate()
            .responseJSON { response in
                print(response.response)
                
                switch response.result {
                case .success(let json):
                    guard let
                        dict = json as? NSDictionary,
                        let encodedData = dict["imageData"] as? String,
                        let imageData = Data(base64Encoded: encodedData, options: NSData.Base64DecodingOptions(rawValue: 0))
                    else {
                        print(json)
                        return
                    }

                    completion(.success(imageData))
                case .failure(let error): completion(.failure(self.parseErrorType(error, data: response.data)))
                }
        }
    }
    
    fileprivate func parseErrorType(_ error: Error, data: Data?) -> Error {
        print(error)
        
        if let errTuple = self.parseErrorData(data) {
            return DoodMonError.httpError(code: errTuple.code, message: errTuple.message)
        }
        
        return DoodMonError.serverError(message: error.localizedDescription)
    }
    
    fileprivate func parseErrorData(_ data: Data?) -> (code: String, message: String)? {
        guard let data = data else {
            return nil
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
            if let
                object = object,
                let code = object["code"] as? String,
                let message = object["message"] as? String
            {
                return (code: code, message: message)
            }
        } catch {
            
        }
        
        return nil
    }
}
