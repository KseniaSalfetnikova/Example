//
//  ListItemAndTextFieldTableViewCell.swift
//  Ditto
//
//  Created by IGA on 26.06.17.
//  Copyright © 2017 Ombori. All rights reserved.
//

import UIKit

protocol ListItemAndTextFieldTableViewCellDelegate: class {
  
  func listItemAndTextFieldCellWillDelete(_ cell: ListItemAndTextFieldTableViewCell)
  
}

@IBDesignable class ListItemAndTextFieldTableViewCell: FieldTableViewCell, ListItemAndTextFieldCell {
  
  // MARK: - Public properties
  
  var listItemTextFieldPlaceholder: String? { didSet { updateCell() } }
  
  var textFieldPlaceholder: String? { didSet { updateCell() } }
  
  @IBInspectable var listItemTextFieldPlaceholderLocalizable: String? { didSet { updateCell() } }
  
  @IBInspectable var textFieldPlaceholderLocalizable: String? { didSet { updateCell() } }
  
  var listItemFormatter: Formatter! { didSet { updateCell() } }
  
  var listItemAndTextModel: ListItemAndTextFieldCellModel {
    return model as! ListItemAndTextFieldCellModel
  }
  
  weak var delegate: ListItemAndTextFieldTableViewCellDelegate?
  
  // MARK: - Overridden properties
  
  override var contentViewNibName: String {
    return "ListItemAndTextFieldTableViewCellContentView"
  }
  
  // MARK: - Outlets
  
  @IBOutlet fileprivate(set) weak var listItemTextField: UITextField!
  
  @IBOutlet fileprivate(set) weak var textField: UITextField!
  
  @IBOutlet fileprivate(set) weak var chevronImageView: UIImageView!
  
  @IBOutlet fileprivate(set) weak var deleteCellButton: UIButton!
  
  // MARK: - Overrides
  
  override func createModel() -> FieldCellModel {
    return ListItemAndTextFieldCellModel(listItemAndTextFieldCell: self)
  }
  
  override func updateCell() {
    super.updateCell()
    listItemTextField.placeholder = textFieldPlaceholder ?? listItemTextFieldPlaceholderLocalizable?.localizedDesignableValue
    textField.placeholder = textFieldPlaceholder ?? textFieldPlaceholderLocalizable?.localizedDesignableValue
    listItemTextField.text = listItemAndTextModel.listItemsValue?.first.map { $0.detailedValue ?? self.listItemFormatter.string(for: $0.value) ?? "" }
    textField.setText(listItemAndTextModel.textValue, preservingSelection: true)
  }
  
  // MARK: - Actions
  
  @IBAction fileprivate func cellWillDelete(_ sender: Any) {
    delegate?.listItemAndTextFieldCellWillDelete(self)
  }
    
}
