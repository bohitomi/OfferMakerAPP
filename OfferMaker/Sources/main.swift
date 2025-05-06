import Foundation
import AppKit
import PDFKit

struct OfferItem {
    var description: String
    var quantity: Int
    var unitPrice: Double
    
    var total: Double {
        return Double(quantity) * unitPrice
    }
}

@MainActor
@main
struct OfferMakerApp {
    static var items: [OfferItem] = []

    static func addItem() {
        print("Enter item description:")
        let desc = readLine() ?? ""

        print("Enter quantity:")
        let qty = Int(readLine() ?? "") ?? 0

        print("Enter unit price (EUR):")
        let price = Double(readLine() ?? "") ?? 0.0

        let newItem = OfferItem(description: desc, quantity: qty, unitPrice: price)
        items.append(newItem)
    }

    static func printSummary() {
        print("\n--- OFFER SUMMARY ---")
        var summaryLines: [String] = []

        for item in items {
            let line = "\(item.quantity)x \(item.description) @ \(item.unitPrice)€ = \(String(format: "%.2f", item.total))€"
            print(line)
            summaryLines.append(line)
        }

        let subtotal = items.map { $0.total }.reduce(0, +)
        let vat = subtotal * 0.27
        let total = subtotal + vat

        print("----------------------")
        print(String(format: "Subtotal: %.2f €", subtotal))
        print(String(format: "VAT (27%%): %.2f €", vat))
        print(String(format: "Total: %.2f €", total))

        print("\nExport to PDF? (y/n)")
        if readLine()?.lowercased() == "y" {
            let fullText = """
            OFFER SUMMARY
            ----------------------
            \(summaryLines.joined(separator: "\n"))

            ----------------------
            Subtotal: \(String(format: "%.2f", subtotal)) €
            VAT (27%): \(String(format: "%.2f", vat)) €
            Total: \(String(format: "%.2f", total)) €
            """
            exportPDF(summary: fullText)
        }
    }

    static func main() {
        print("OFFER MAKER APP")

        while true {
            print("\nChoose an option:")
            print("1. Add item")
            print("2. Print summary")
            print("3. Exit")

            let choice = readLine() ?? ""

            switch choice {
            case "1":
                addItem()
            case "2":
                printSummary()
            case "3":
                print("Exiting.")
                return
            default:
                print("Invalid choice.")
            }
        }
    }
}

func exportPDF(summary: String) {
    let savePanel = NSSavePanel()
    savePanel.allowedFileTypes = ["pdf"]
    savePanel.nameFieldStringValue = "Offer.pdf"

    savePanel.begin { result in
        guard result == .OK, let url = savePanel.url else { return }

        let pdf = PDFDocument()
        let page = PDFPage(image: renderImage(from: summary))
        pdf.insert(page!, at: 0)
        pdf.write(to: url)
    }
}

func renderImage(from text: String) -> NSImage {
    let size = NSSize(width: 600, height: 800)
    let image = NSImage(size: size)
    image.lockFocus()

    let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14)]
    let lines = text.components(separatedBy: "\n")

    for (index, line) in lines.enumerated() {
        line.draw(at: NSPoint(x: 40, y: size.height - 60 - CGFloat(index * 20)), withAttributes: attributes)
    }

    image.unlockFocus()
    return image
}
