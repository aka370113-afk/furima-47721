const price = () => {
  const input = document.getElementById("item-price")
  if (!input) return
  input.addEventListener("input", () => {
    const p = parseInt(input.value, 10) || 0
    const fee = Math.floor(p * 0.1)
    document.getElementById("add-tax-price").textContent = p ? fee.toLocaleString() : ""
    document.getElementById("profit").textContent = p ? (p - fee).toLocaleString() : ""
  })
}

window.addEventListener("turbo:load", price)
window.addEventListener("turbo:render", price)
