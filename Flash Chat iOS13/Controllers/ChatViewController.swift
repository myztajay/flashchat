//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "flashchat"
        navigationItem.hidesBackButton = true
        loadMessages()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    }
    func loadMessages() {
        db.collection("messages")
        .order(by: "date")
        .addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.messages = []
                if let querydocuments = querySnapshot?.documents {
                    for document in querydocuments {
                        let data = document.data()
                        if let sender = data["sender"], let body = data["body"] {
                            let currentMessage = Message(sender: sender as! String, body: body as! String)
                            self.messages.append(currentMessage)
                        }
                        print("\(document.documentID) => \(document.data())")
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let sender = Auth.auth().currentUser?.email, let messsageBody = messageTextfield.text {
            // Add a new document with a generated ID
            var ref: DocumentReference? = nil
            ref = db.collection("messages").addDocument(data: [
                "sender": sender,
                "body": messsageBody,
                "date": Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.messageTextfield.text = ""
                }
            }
        } else {
            print("no user")
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // call out how many rows
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // we call out the type of cell to create
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        as! MessageCell
        cell.label?.text = messages[indexPath.row].body
        return cell
    }
}

