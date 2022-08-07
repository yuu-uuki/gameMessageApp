//
//  UrlTableViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/08/23.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class UrlTableViewController: UITableViewController {

  var urlNames: [String] = ["パッチノート", "最新ニュース"]
  var urls: [String] = [
    "https://www.ea.com/ja-jp/games/apex-legends/news/ascension-patch-notes",
    "https://www.ea.com/ja-jp/games/apex-legends/news",
  ]
  var selectedUrl: String!
  let uid = Auth.auth().currentUser!.uid as String
  var documentCount = 2

  let db = Firestore.firestore()

  override func viewDidLoad() {
    super.viewDidLoad()
    for view in tableView.subviews {
      if view is UIToolbar {
        let toolbar = view as! UIToolbar
        toolbar.backgroundColor = UIColor.clear
        toolbar.isTranslucent = true
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
      }
    }
    self.getData(uid: uid)
    let imageView = UIImageView(
      frame: CGRect(
        x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
    let image = UIImage(named: "apex_wall")
    imageView.image = image
    imageView.alpha = 1
    self.tableView.backgroundView = imageView
    tableView.register(
      UINib(nibName: "UrlTableViewCell", bundle: nil), forCellReuseIdentifier: "UrlCell")
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  // MARK: - Table view data source

  /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return urlNames.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "UrlCell", for: indexPath)
      as! UrlTableViewCell
    cell.UrlLabel?.text = urlNames[indexPath.row]
    cell.backgroundColor = UIColor.clear
    cell.contentView.backgroundColor = UIColor.clear
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedUrl = urls[indexPath.row]
    performSegue(withIdentifier: "webView", sender: nil)
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 100
  }

  //スワイプしたセルを削除
  override func tableView(
    _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      urlNames.remove(at: indexPath.row)
      urls.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
    }
  }

  @IBAction func addClick(_ sender: Any) {
    let alertController = UIAlertController(
      title: "タイトルとURLを入力してください", message: "", preferredStyle: .alert)

    alertController.addTextField { textField in
      textField.placeholder = "タイトル"
    }

    alertController.addTextField { textField in
      textField.placeholder = "URL"
    }

    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action -> Void in
    }
    alertController.addAction(cancelAction)

    let addAction = UIAlertAction(title: "追加", style: .default) { action -> Void in
      let titles = alertController.textFields![0].text!
      let url = alertController.textFields![1].text!
      //let uid = Auth.auth().currentUser!.uid as String
      self.addData(titles: titles, url: url, uid: self.uid)
    }

    alertController.addAction(addAction)
    present(alertController, animated: true, completion: nil)
  }

  func addData(titles: String, url: String, uid: String) {
    var ref: DocumentReference? = nil
    ref = self.db.collection("users").document(uid).collection("urlList").document(
      String(documentCount))
    ref?.setData([
      "title": titles,
      "url": url,
    ]) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
        self.urlNames.append(titles)
        self.urls.append(url)
        self.documentCount += 1
        self.tableView.reloadData()
      }
    }
  }

  func getData(uid: String) {
    let docRef = db.collection("users").document(uid).collection("urlList")
    docRef.getDocuments { (querySnapshot, error) in
      if let error = error {
        print("Error getting documents: \(error)")
      } else {
        self.documentCount = querySnapshot?.documents.count ?? 0
        for document in querySnapshot!.documents {
          let getTitle = document.get("title") as! String
          let getUrl = document.get("url") as! String
          self.urlNames.append(getTitle)
          self.urls.append(getUrl)
        }
        self.tableView.reloadData()
      }
    }
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
    let vc = segue.destination as! WebViewController
    vc.url = selectedUrl
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }

}
