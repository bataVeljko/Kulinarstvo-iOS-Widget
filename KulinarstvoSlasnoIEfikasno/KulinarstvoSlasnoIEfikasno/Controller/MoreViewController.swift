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
    
    lazy var myAccountViewController = MyAccountViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.isUserLoggedIn = (Auth.auth().currentUser != nil && !(Auth.auth().currentUser?.isAnonymous ?? false))
    }
}

//MARK: - UITableViewDataSource
extension MoreViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isUserLoggedIn ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var contentConfiguration = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            contentConfiguration.text = self.isUserLoggedIn ? "Moj nalog" : "Ulogujte se"
        case 1:
            contentConfiguration.text = self.isUserLoggedIn ? "Odjavi se" : "Napravite nalog"
        case 2:
            contentConfiguration.text = self.isUserLoggedIn ? "Obriši nalog" : "" // TODO: Make text red
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
        case 2:
            self.isUserLoggedIn ? self.deleteAccount() : ()
        default:
            return
        }
    }
}

//MARK: - AccountViewController calling
extension MoreViewController {
    private func showLogin() {
        self.createAndPresentConttroller(isLogin: true)
    }
    
    private func showSignUp() {
        self.createAndPresentConttroller(isSignUp: true)
    }
    
    private func createAndPresentConttroller(isLogin: Bool = false, isSignUp: Bool = false, isEditAccount: Bool = false, isChangePassword: Bool = false) {
        let accountViewController = AccountViewController(isLogin: isLogin, isSignUp: isSignUp, isEditData: isEditAccount, isChangePassword: isChangePassword)
        accountViewController.delegate = self
        accountViewController.modalPresentationStyle = .popover
        self.present(accountViewController, animated: true)
    }
    
    private func showMyAccount() {
        self.myAccountViewController.delegate = self
        self.myAccountViewController.modalPresentationStyle = .popover
        self.present(self.myAccountViewController, animated: true)
    }
    
    private func logout() {
        AuthenticationService.singOut()
        self.isUserLoggedIn = false
        Datafeed.shared.currentUser = nil
    }
    
    private func deleteAccount() {
        guard Datafeed.shared.currentUser != nil else {
            return
        }
//        Datafeed.shared.userRepository.deleteUser(Datafeed.shared.currentUser!)
        AuthenticationService.deleteUser()
        self.isUserLoggedIn = false
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
    
    func userPhotoUrlSuccesfullySaved(_ controller: AccountViewController) {
        self.myAccountViewController.getUserProfileImage()
    }
    
    func userDataChanged(_ controller: AccountViewController) {
        self.showMyAccount()
    }
    
    func userChangedPassword(_ controller: AccountViewController){
        self.showMyAccount()
    }
}

//MARK: - MyAccountViewControllerDelegate
extension MoreViewController : MyAccountViewControllerDelegate {
    func myAccountViewControllerChangeDataButtonClicked(_ controller: MyAccountViewController) {
        self.createAndPresentConttroller(isEditAccount: true)
    }
    
    func myAccountViewControllerChangePasswordButtonClicked(_ controller: MyAccountViewController) {
        self.createAndPresentConttroller(isChangePassword: true)
    }
}
