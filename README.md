# CellSwiperDeleter
Swift library for deleting tableview cell by using left swipe gesture.

#### Step 01

Add CellSwiperDeleter folder in you project folder

#### Step 02

Go to your view's UITableViewCell class.Make sure that tableView class has a view which contains all the UI elements in the cell. Connect that view your tableview class
```
  class MyTableViewCell: UITableViewCell {
  
    @IBOutlet weak var backgroundMainView: UIView!
    
    
    ........
  }
```

#### Step 03

Add parentVC and index paramters on TableViewCell class. And also add cellDeleter paramter. 

```
  class MyTableViewCell: UITableViewCell {
      private var cellDeleter: CellSwiperDeleterAttachment!
    
      var parentVC: AttachmentsViewController!
      var index: Int = 0 {
          didSet {
              self.cellSwiperDeleterConnector()
          }
      }
      
      ...........
  }

```

#### Step 04

Update paranteVC and index parameter from the parent ViewController.

```
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
          cell.parentVC = self
          cell.index = indexPath.row
        return cell
    }

```

#### Step 05

Initialise  ``cellDeleter`` on ``awakeFromNib()``.

```
      override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
        
          self.cellDeleter = CellSwiperDeleter(parentVC: nil, cellView: self, cellBackgroundView: self.backgroundMainView, isSwipable: true, index: self.index)
          self.cellDeleter!.connectGuesture()
    }


```


#### Step 06

Add ``cellSwiperDeleterConnector`` on UITableViewCell.

```
      func cellSwiperDeleterConnector() {
        self.cellDeleter.index = self.index
        self.cellDeleter.parentVC = self.parentVC
        self.cellDeleter.isSwipable = true  // You can set swipable or not for each cell
    }

```

#### Step 07

Add Guesture delegates for UITableViewCell.

```
  // MARK: - Cell Swipe Delete Manage

  extension MyTableViewCell {
    
      override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
          return false
      }
    
      override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
          if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
              let translation = panGestureRecognizer.translation(in: superview)
              if fabs(translation.x) > fabs(translation.y) {
                  return true
              }
              return false
          }
          return false
      }
    
}


```

#### Step 08

Go to the ``CellSwipeDeleter`` class and change parentVC paramter type, backgroundview radius and add what happend when delete cell from the tableview. (Go through with the class comments //)

```
  class CellSwipeDeleter {
    
    public var parentVC: ViewController?   /// Update Parent VC
    
    ........
    
    /// Change Paranet VC type
    
    init(parentVC: ViewController?, cellView: UITableViewCell, cellBackgroundView: UIView, isSwipable: Bool, index: Int) {
        self.parentVC = parentVC
        self.cellView = cellView
        self.cellBackgroundView = cellBackgroundView
        self.isSwipable = isSwipable
        self.index = index
    }
  }
  
  
  .........
  
  
      public func connectGuesture() {
       ...........
        
        /// Change Background view Radius
        self.editBackgroundView.layer.cornerRadius = 10.0
        
    }
    
    
        /// MARK: - Remove TableView Item
    
    private func deleteItemFromTable() {
       
        self.parentVC!.putToTrash(requestID: requestID, index: self.index)  // Call function on Parant VC on removal
        
        self.parentVC!.purchaseRequests.remove(at: self.index)   /// Remove element from Array
        self.parentVC!.tableView.beginUpdates()
        self.parentVC!.tableView.deleteRows(at: [IndexPath(item: self.index, section: 0)], with: .left)
        self.parentVC!.tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.parentVC!.tableView.reloadData()
        })
    }

```





