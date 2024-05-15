//
//  newsViewController.swift
//  SmartTravelApp
//
//  Created by student on 16/5/2024.
//

import UIKit

class newsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var theTable: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var newsArticles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.startAnimating()
        
        theTable.delegate = self
        theTable.dataSource = self
        
        getNewsData { [weak self] result in
            switch result {
            case .success(let newsResponse):
                self?.newsArticles = newsResponse.articles
                DispatchQueue.main.async {
                    self?.loader.startAnimating()
                    self?.loader.isHidden = true
                    self?.theTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        let article = newsArticles[indexPath.row]
        cell.textLabel?.text = article.title
      //  cell.detailTextLabel?.text = "\(article.author) | \(article.publishedAt)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = newsArticles[indexPath.row]
        print(article.url)
        
        // Perform segue to another view controller or handle the URL as needed
        FunctionViewController.weburl = article.url
        self.performSegue(withIdentifier: "showmewsweb", sender: true)
    }
    
    // MARK: - News Data
    
    struct NewsResponse: Codable {
        let status: String
        let totalResults: Int
        let articles: [Article]
    }
    
    struct Article: Codable {
        let source: Source
        let author: String
        let title: String
        let description: String?
        let url: String
        let urlToImage: String?
        let publishedAt: String
        let content: String?
    }
    
    struct Source: Codable {
        let id: String?
        let name: String
    }
    
    func getNewsData(completion: @escaping (Result<NewsResponse, Error>) -> Void) {
        let urlString = "https://newsapi.org/v2/top-headlines?country=au&apiKey=1d88b98768904c10ac656a694e17f8d8"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                    completion(.success(newsResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
