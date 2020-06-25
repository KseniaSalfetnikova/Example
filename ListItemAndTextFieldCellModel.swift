//
//  ListItemAndTextFieldCellModel.swift
//  Ditto
//
//  Created by IGA on 26.06.17.
//  Copyright © 2017 Ombori. All rights reserved.
//

import UIKit

protocol ListItemAndTextFieldCell: FieldCell {
  
  var textField: UITextField! { get }
  
}

class ListItemAndTextFieldCellModel: FieldCellModel, DoneInputAccessoryViewDelegate, UITextFieldDelegate {
  
  private struct CompoundValue {
    var listItems: [ListItemSelectionViewController.ListItem]?
    var text: String?
  }
  
  // MARK: - Public properties
  
  var listItemsValue: [ListItemSelectionViewController.ListItem]? {
    get {
      guard let v = value as? CompoundValue else { return nil }
      return v.listItems
    }
    set {
      var v = value as? CompoundValue ?? CompoundValue()
      v.listItems = newValue
      value = v
    }
  }

  var textValue: String? {
    get {
      guard let v = value as? CompoundValue else { return nil }
      return v.text
    }
    set {
      var v = value as? CompoundValue ?? CompoundValue()
      v.text = newValue
      value = v
    }
  }
  
  var singleListItemValue: Any? {
    get {
      return listItemsValue?.first?.value
    }
    set {
      listItemsValue = newValue.map { [(value: $0, detailedValue: nil)] }
    }
  }
  
  var listItemAndTextCell: ListItemAndTextFieldCell {
    return fieldCell as! ListItemAndTextFieldCell
  }
  
  var transformsValueToUppercase: Bool = false
  
  // MARK: - Initialization
  
  init(listItemAndTextFieldCell: FieldCell) {
    super.init(fieldCell: listItemAndTextFieldCell)
    listItemAndTextCell.textField.configureDoneInputAccessoryWithDelegate(self)
    listItemAndTextCell.textField.delegate = self
    valueValidationBlock = { value in
      guard let v = value as? CompoundValue else { return false }
      return v.text?.isEmpty == false && v.listItems?.isEmpty == false
    }
  }
  
  // MARK: - Text field delegate
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
    textValue = newText.isEmpty ? nil : newText
    delegate?.fieldCellModel(self, didChangeValue: value)
    return false
  }
  
  // MARK: - Done input accessory view delegate
  
  func doneInputAccessoryViewDidPressDone(_ view: DoneInputAccessoryView) {
    _ = listItemAndTextCell.textField.resignFirstResponder()
  }

}
