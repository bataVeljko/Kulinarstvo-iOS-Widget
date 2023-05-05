//
//  MoreViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import UIKit
import FirebaseAuth
import Firebase

class MoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var isUserLoggedIn = false {
        didSet {
            if oldValue != isUserLoggedIn {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.isUserLoggedIn = Auth.auth().currentUser != nil
    }
}

//MARK: - UITableViewDataSource
extension MoreViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var contentConfiguration = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            contentConfiguration.text = self.isUserLoggedIn ? "Moji nalog" : "Ulogujte se"
        case 1:
            contentConfiguration.text = self.isUserLoggedIn ? "Odjavi se" : "Napravite nalog"
        default:
            contentConfiguration.text = "Ulogujte se"
        }
        
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MoreViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 0:
            self.isUserLoggedIn ? self.showMyAccount() : self.showLogin()
        case 1:
            self.isUserLoggedIn ? self.logout() : self.showSignUp()
        default:
            return
        }
    }
}

//MARK: - AccountViewController calling
extension MoreViewController {
    private func showLogin() {
        self.createAndPresentConttroller(isSignUp: false)
    }
    
    private func showSignUp() {
        self.createAndPresentConttroller(isSignUp: true)
    }
    
    private func createAndPresentConttroller(isSignUp: Bool) {
        let accountViewController = AccountViewController(isSignUp: isSignUp)
        accountViewController.delegate = self
        accountViewController.modalPresentationStyle = .popover
        self.present(accountViewController, animated: true)
    }
    
    private func showMyAccount() {
        let myAccountViewController = MyAccountViewController()
        myAccountViewController.modalPresentationStyle = .popover
        self.present(myAccountViewController, animated: true)
    }
    
    private func logout() {
        AuthenticationService.singOut()
        self.isUserLoggedIn = false
        Datafeed.shared.currentUser = nil
    }
}

//MARK: - AccountViewControllerDelegate
extension MoreViewController : AccountViewControllerDelegate {
    func userLoggedInSuccesfully(_ controller: AccountViewController) {
        controller.dismiss(animated: true)
        self.isUserLoggedIn = Auth.auth().currentUser != nil
        if self.isUserLoggedIn {
            self.showMyAccount()
        }
    }
}
