import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
	
//	This is the ID from the product that you register under your Apple Developer account
//	Here is just a random string since I don't want pay and register this app
	let productID = "com.sunnyle.Inspiquo.PremiumQuotes"
	
	var quotesToShow = [
		"Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
		"All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
		"It does not matter how slowly you go as long as you do not stop. – Confucius",
		"Everything you’ve ever wanted is on the other side of fear. — George Addair",
		"Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
		"Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
	]
	
	let premiumQuotes = [
		"Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
		"I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
		"There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
		"It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
		"Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
		"Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		SKPaymentQueue.default().add(self)
		
		if isPurchased() {
			showPremiumQuotes()
		}
	}

	// MARK: - UITableViewDataSource methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isPurchased() ? quotesToShow.count : quotesToShow.count + 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

		var content = cell.defaultContentConfiguration()
		if indexPath.row < quotesToShow.count {
			content.text = quotesToShow[indexPath.row]
			content.textProperties.color = .black
			cell.accessoryType = .none
		} else {
			content.text = "Get More Quotes"
			content.textProperties.color = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
			cell.accessoryType = .disclosureIndicator
		}
		content.textProperties.numberOfLines = 0
		cell.contentConfiguration = content
		return cell
	}
	
	// MARK: - UITableViewDelegate methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == quotesToShow.count {
			buyPremiumQuotes()
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - In-app purchase methods
	func buyPremiumQuotes() {
		if SKPaymentQueue.canMakePayments() {
			let paymentRequest = SKMutablePayment()
			paymentRequest.productIdentifier = productID
			SKPaymentQueue.default().add(paymentRequest)
		} else {
			print("User can't make payment")
		}
	}
	
	func showPremiumQuotes() {
		UserDefaults.standard.set(true, forKey: productID)
		quotesToShow.append(contentsOf: premiumQuotes)
		tableView.reloadData()
	}
	
	func isPurchased() -> Bool {
		return UserDefaults.standard.bool(forKey: productID)
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			if transaction.transactionState == .purchased {
				print("Transaction successful!")
				showPremiumQuotes()
				SKPaymentQueue.default().finishTransaction(transaction)
			} else if transaction.transactionState == .failed {
				if let error = transaction.error {
					print("Transaction failed due to error: \(error.localizedDescription)")
				}
				SKPaymentQueue.default().finishTransaction(transaction)
			} else if transaction.transactionState == .restored {
				showPremiumQuotes()
				navigationItem.setRightBarButton(nil, animated: true)
				SKPaymentQueue.default().finishTransaction(transaction)
			}
		}
	}

	@IBAction func restorePressed(_ sender: UIBarButtonItem) {
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
}
