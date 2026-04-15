import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["price", "fee", "profit"]

  connect() {
    this.update()
  }

  update() {
    const raw = (this.priceTarget.value || "").replace(/\D/g, "")
    if (raw === "") {
      this.feeTarget.textContent = ""
      this.profitTarget.textContent = ""
      return
    }
    const price = parseInt(raw, 10)
    const fee = Math.floor(price * 0.1)
    const profit = price - fee
    this.feeTarget.textContent = fee.toLocaleString("ja-JP")
    this.profitTarget.textContent = profit.toLocaleString("ja-JP")
  }
}
