//
//  ChatRoomTableViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/10/17.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ChatRoomTableViewController: UITableViewController {

  var chatRoom = "roomName"
  var roomNameDictionary = [(String, String)]()
  let db = Firestore.firestore()
  var selectedRow: Int!
  var imageNames = ["diamond,master,predator", "platina,diamond3", "bronze,silver,gold", "orinpus"]

  override func viewDidLoad() {
    super.viewDidLoad()
    getData()
    tableView.register(
      UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
    self.tableView.backgroundColor = UIColor.black
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  func getData() {
    let docRef = db.collection("rooms")
    docRef.getDocuments { (querySnapshot, error) in
      if let error = error {
        print("Error getting documents: \(error)")
      } else {
        self.roomNameDictionary.removeAll()
        for document in querySnapshot!.documents {
          let nameToDoc = (document.get("name") as! String, document.documentID)
          self.roomNameDictionary.append(nameToDoc)
        }
        self.tableView.reloadData()
      }
    }
  }

  // MARK: - Table view data source

  /*override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 0
     }*/

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return roomNameDictionary.count
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 160
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let nameToDoc = roomNameDictionary[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
      as! CustomTableViewCell
    cell.roomNameLabel?.text = nameToDoc.0
    cell.roomBackgroundImage?.image = UIImage(named: imageNames[indexPath.row])
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.row
    performSegue(withIdentifier: "chat", sender: nil)
  }

  /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

  /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

  /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

  /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! ChatViewController
    vc.roomName = roomNameDictionary[selectedRow].0
    vc.roomDocId = roomNameDictionary[selectedRow].1
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }

}
