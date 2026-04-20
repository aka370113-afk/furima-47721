const price = () => {
  const input = document.getElementById("item-price")
  if (!input) return
  if (input.dataset.priceCalcBound === "true") return
  input.dataset.priceCalcBound = "true"

  const sync = () => {
    const p = parseInt(input.value, 10) || 0
    const fee = Math.floor(p * 0.1)
    const feeEl = document.getElementById("add-tax-price")
    const profitEl = document.getElementById("profit")
    if (feeEl) feeEl.textContent = p ? fee.toLocaleString() : ""
    if (profitEl) profitEl.textContent = p ? (p - fee).toLocaleString() : ""
  }

  input.addEventListener("input", sync)
  // 初期表示・バリデーション失敗後の再表示でも、入力済み価格に合わせて手数料・利益を出す
  sync()
}

window.addEventListener("turbo:load", price)
window.addEventListener("turbo:render", price)
