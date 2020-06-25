//
//  IdentityVerificationPersonalInformationFormController.swift
//  Ditto
//
//  Created by IGA on 06.07.17.
//  Copyright © 2017 Ombori. All rights reserved.
//

import UIKit

class IdentityVerificationPersonalInformationFormController: NSObject, FormControlling, AddressFormTableViewControllerDelegate {
  
  // MARK: - Public properties
  
  fileprivate(set) var fieldCells: [FieldCell] = [] {
    didSet {
      let old = oldValue.flatMap { $0 as? UITableViewCell }
      let new = fieldCells.flatMap { $0 as? UITableViewCell }
      if old == new { return }
      self.delegate?.formControllerDidChangeFieldCells(self)
    }
  }
  
  var countriesProvider: CountriesProvider = CountriesProvider.sharedProvider()
  
  var queryListsManager: QueryListsManager = QueryListsManager.sharedManager()
  
  var documentRecognitionResult: DocumentRecognitionResult?
  
  weak var delegate: FormControllerDelegate?
  
  // MARK: - Outlets
  
  @IBOutlet fileprivate(set) weak var firstNameFieldCell: TextFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var lastNameFieldCell: TextFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var maidenNameFieldCell: TextFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var dateOfBirthFieldCell: DateFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var genderFieldCell: RadioFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var addressFieldCell: AddressFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var addressSinceDateFieldCell: DateFieldTableViewCell!

  @IBOutlet fileprivate(set) weak var addressHostedByThirdPartyFieldCell: RadioFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var placeOfBirthFieldCell: AddressFieldTableViewCell!
  
  @IBOutlet fileprivate(set) weak var nationalityFieldCell: SingleListItemFieldTableViewCell!
  
  // MARK: - Private properties
  
  fileprivate var allFieldCells: [FieldCell] {
    return [
      firstNameFieldCell,
      lastNameFieldCell,
      maidenNameFieldCell,
      dateOfBirthFieldCell,
      genderFieldCell,
      addressFieldCell,
      addressSinceDateFieldCell,
      addressHostedByThirdPartyFieldCell,
      placeOfBirthFieldCell,
      nationalityFieldCell,
    ]
  }
  
  fileprivate var enterAddressCell: Bool = false
  
  // MARK: - Public API
  
  func setupFieldCells() {
    fieldCells = allFieldCells
    allFieldCells.forEach {
      $0.model.delegate = self
      ($0 as? FieldTableViewCell)?.showsErrorView = true
    }
    maidenNameFieldCell.model.isRequired = false
    addressFieldCell.addressModel.requiredAddressComponents = [.streetFirstRow, .postalCode, .locality, .country]
    placeOfBirthFieldCell.addressModel.requiredAddressComponents = [.locality, .country, .department]
    nationalityFieldCell.listItemFormatter = CountryFormatter()
    setDefaultFieldValues()
  }
  
  func prepareAddressFormTableViewController(_ controller: AddressFormTableViewController, forCell cell: FieldCell) {
    controller.delegate = self
    controller.countriesProvider = self.countriesProvider
    controller.queryListsManager = self.queryListsManager
    switch cell {
    case let c where c === placeOfBirthFieldCell:
      configureAddressFormTableViewController(controller, forAddressFieldCell: placeOfBirthFieldCell)
      enterAddressCell = false
    case let c where c === addressFieldCell:
      configureAddressFormTableViewController(controller, forAddressFieldCell: addressFieldCell)
      enterAddressCell = true
    default: break
    }
  }
  
  func prepareListItemSelectionViewController(_ controller: ListItemSelectionViewController, forCell cell: FieldCell) {
    switch cell {
    case let c where c === nationalityFieldCell:
      controller.showsDetailedListItemCell = false
      controller.itemFetchingClosure = { [unowned self] completion in
        completion(.success(self.countriesProvider.sortedCountries))
      }
      configureListItemSelectionViewController(controller, forSingleListItemFieldCell: nationalityFieldCell)
    default: break
    }
  }
  
  // MARK: - Private API
  
  fileprivate func configureListItemSelectionViewController(_ controller: ListItemSelectionViewController, forSingleListItemFieldCell cell: SingleListItemFieldTableViewCell) {
    controller.title = cell.fieldTitleLabel?.text
    controller.selectedItem = cell.listItemModel.singleListItemValue
    controller.itemFormatter = cell.listItemFormatter
    controller.selectionClosure = { [unowned self] listItems in
      cell.listItemModel.listItemsValue = listItems
      self.delegate?.formControllerDidChangeFieldCells(self)
      _ = controller.navigationController?.popViewController(animated: true)
    }
  }
  
  fileprivate func configureAddressFormTableViewController(_ controller: AddressFormTableViewController, forAddressFieldCell cell: AddressFieldTableViewCell) {
    controller.requiredAddressComponents = Set(cell.addressModel.requiredAddressComponents)
    controller.addressComponents = cell.addressModel.addressValue ?? AddressComponents()
  }
  
  fileprivate func setDefaultFieldValues() {
    guard let recognitionResult = self.documentRecognitionResult else { return }
    firstNameFieldCell.model.value = recognitionResult.firstName
    lastNameFieldCell.model.value = recognitionResult.lastName
    dateOfBirthFieldCell.model.value = recognitionResult.birthDate
    genderFieldCell.model.value = recognitionResult.gender.rawValue
    var address = AddressComponents()
    address.streetFirstRow = recognitionResult.address
    address.postalCode = recognitionResult.postalCode
    address.locality = recognitionResult.town
    addressFieldCell.addressModel.addressValue = address
    var placeOfBirth = AddressComponents()
    placeOfBirth.locality = recognitionResult.birthPlace
    placeOfBirthFieldCell.addressModel.addressValue = placeOfBirth
  }
  
  // MARK: - Field cell model delegate
  
  func fieldCellModel(_ model: FieldCellModel, didChangeValue value: Any?) {
    delegate?.formControllerDidChangeFieldCells(self)
  }
  
  // MARK: - Address form table view controller delegate
  
  func addressFormTableViewController(_ controller: AddressFormTableViewController, didChangeAddressComponents addressComponents: AddressComponents) {
    if enterAddressCell {
      addressFieldCell.addressModel.addressValue = addressComponents
    } else {
      placeOfBirthFieldCell.addressModel.addressValue = addressComponents
    }
    self.delegate?.formControllerDidChangeFieldCells(self)
  }

}
