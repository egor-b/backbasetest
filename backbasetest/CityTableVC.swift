//
//  CityTableVC.swift
//  backbasetest
//
//  Created by Egor Bryzgalov on 2/28/19.
//  Copyright © 2019 Egor Bryzgalov. All rights reserved.
//

import UIKit

class CityTableVC: UITableViewController, UISearchResultsUpdating {
    
    var searchController = UISearchController()
    let progressView = UIProgressView(progressViewStyle: .bar)
    
    var city = [City]()
    var sortCity = [City]()
    var filteredCity = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Cities"
        makeSearchController()
        setupProgressView()
        progressView.progress = 0.0
        ManagerData.shared().readJSON { (temp:[City]?, progress:Float) in
            DispatchQueue.main.async {
                self.city = temp!
                self.tableView.reloadData()
                self.progressView.setProgress(progress, animated: true)
                if progress == 1.0 {
                    self.progressView.isHidden = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if progressView.isHidden && progressView.progress != 1.0 {
            progressView.isHidden = false
        }
    }
    
    func makeSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            searchController.hidesNavigationBarDuringPresentation = true
        }
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .black
        searchController.searchBar.placeholder = "Write city name ..."
    }

    func updateSearchResults(for searchController: UISearchController) {
        filteredCity = city.filter({ (temp:City) -> Bool in
            if temp.name.contains(searchController.searchBar.text!) {
                return true
            } else {
                return false
            }
        })
        tableView.reloadData()
    }

    private func setupProgressView() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(progressView)
    
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            
            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
            ])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCity.count
        } else {
            return city.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        if searchController.isActive {
            cell.textLabel?.text = "\(filteredCity[indexPath.row].name), \(filteredCity[indexPath.row].country)"
        } else {
            cell.textLabel?.text = "\(city[indexPath.row].name), \(city[indexPath.row].country)"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            progressView.isHidden = true
            if searchController.isActive {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destinationVC = segue.destination as! MapVC
                    destinationVC.city = filteredCity[indexPath.row]
                    searchController.dismiss(animated: true, completion: nil)
                }
            } else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destinationVC = segue.destination as! MapVC
                    destinationVC.city = city[indexPath.row]
                }
            }
            
        }
    }
}
