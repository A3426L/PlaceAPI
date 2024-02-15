//
//  ContentView.swift
//  Google map test
//
//  Created by aru on 2024/02/15.
//

import SwiftUI

struct Comment: Codable {
    var id: Int
    var name: String
    var email: String
    var body: String
}
struct PlaceResponse: Codable {
    let htmlAttributions: [String]
    let results: [Place]
    let status: String
}

struct Place: Codable, Identifiable {
    let id = UUID()
    let placeId: String
    let types: [String]
    let vicinity: String
}


struct Root: Codable {
    let result: PlaceDetail
}

struct PlaceDetail: Codable {
    let name: String
    let photos: [Photo]?
    let reviews: [Review]?
}

struct Photo: Codable {
    let photoReference: String
}

struct Review: Codable {
    let authorName: String
    let rating: Int
    let relativeTimeDescription: String
    let text: String
}






class SearchPlace:ObservableObject{
    @Published var api_key = ""
    @Published var radius = ""
    
    init(){
        self.api_key = "＊＊＊＊＊＊"
        self.radius = "100"//めーとる
    }
    
    func get_placeID(place_name :String,latitude:String,longitude:String){
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
        
        let location = latitude + "," + longitude
        
        urlComponents.queryItems = [
            URLQueryItem(name: "language", value: "ja"),
            URLQueryItem(name: "keyword", value: place_name),
            URLQueryItem(name: "radius", value: radius),
            URLQueryItem(name:"location",value: location),
            URLQueryItem(name: "key", value: api_key)
        ]
        let request = URLRequest(url: urlComponents.url!)
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Invalid data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let placeResponse = try decoder.decode(PlaceResponse.self, from: data)
                
                if let places = placeResponse.results.first{
                    let placeId = places.placeId
                    let address = places.vicinity
                    let types = places.types
                    
                    print("Place ID: \(placeId)")
                    print("Address: \(address)")
                    print("Types: \(types)")
                }
                print("--------------------")
                
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    
    func place_detail(place_id:String ,fields:String){
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json")!
        
        
        
        urlComponents.queryItems = [
            URLQueryItem(name: "language", value: "ja"),
            URLQueryItem(name: "place_id", value: place_id),
            URLQueryItem(name: "fields", value: fields),
            URLQueryItem(name: "key", value: api_key)
        ]
        let request = URLRequest(url: urlComponents.url!)
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Invalid data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let placeResponse = try decoder.decode(Root.self, from: data)
                
                let placeDetail = placeResponse.result
                if let photos = placeDetail.photos {
                    for photo in photos {
                        let photoReference = photo.photoReference
                        print("Photo Reference: \(photoReference)")
                    }
                }
                
                let placeName = placeDetail.name
                print("Place Name: \(placeName)")
                
                if let reviews = placeDetail.reviews {
                   for review in reviews {
                       let authorName = review.authorName
                       let rating = review.rating
                       let relativeTime = review.relativeTimeDescription
                       let text = review.text

                       print("authorName \(authorName), Rating: \(rating), Time: \(relativeTime)")
                       print("Text: \(text)")
                       
                       print("--------------------")
                   }
               }
                
                
                print("--------------------")
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    func place_image(photoReference: String){
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/photo")!
        
        let maxWidth = 400
        urlComponents.queryItems = [
            URLQueryItem(name: "maxwidth", value: "\(maxWidth)"),
            URLQueryItem(name: "photo_reference", value: photoReference),
            URLQueryItem(name: "key", value: api_key)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Invalid data")
                return
            }
            
            print(data)
            if let image = UIImage(data: data) {
                        // ここでがぞうしょり〜〜
                        print("Fetched photo successfully")
                    } else {
                        print("Invalid photo data")
                    }
        }.resume()
        
    }
}
    
    
    

struct ContentView: View {
    @ObservedObject var Search_place = SearchPlace()

    var body: some View {
        Button(action:{
            Search_place.get_placeID(place_name: "パスタ・ビンコロ", latitude: "34.923611",longitude: "135.691546")
        }){
            Text("名前検索")
        }
        Button(action:{
            Search_place.place_detail(place_id: "ChIJXWPBvmgEAWARMemQkRKOJnA",fields: "")
        }){
            Text("詳細検索")
        }
        Button(action:{
            Search_place.place_image(photoReference:" ATplDJZWdSYsToSYD5q3Mi2R4irr3dtFpCOgJgP9dgMaH2HNl4ezwXYuH9MUnZ5M6atXPk-KZ95wuO0BPEq4ndL4mEmq5gibDOwHyhW5k71zHPqzeqA7wiG9qz_81LJVUOR1WjbLmRGicfO761_7lafLEYMRF3tZtukAHMC4m3f0ulRBMvk1")
        }){
            Text("画像検索")
        }
        
    }
}

#Preview {
    ContentView()
}
