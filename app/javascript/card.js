const pay = () => {
  const form = document.getElementById("charge-form");
  if (!form) return;
  if (typeof gon === "undefined" || !gon.public_key) return;

  const publicKey = gon.public_key;
  const payjp = Payjp(publicKey);
  const elements = payjp.elements();
  const numberElement = elements.create("cardNumber");
  const expiryElement = elements.create("cardExpiry");
  const cvcElement = elements.create("cardCvc");

  numberElement.mount("#number-form");
  expiryElement.mount("#expiry-form");
  cvcElement.mount("#cvc-form");

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    payjp.createToken(numberElement).then(function (response) {
      if (response.error) {
        window.alert(
          "カード情報を確認してください: " + (response.error.message || "")
        );
        return;
      }
      const token = response.id;
      const renderDom = document.getElementById("charge-form");
      const existing = renderDom.querySelector('input[name="token"]');
      if (existing) existing.remove();
      const tokenObj = `<input value="${token}" name="token" type="hidden" />`;
      renderDom.insertAdjacentHTML("beforeend", tokenObj);
      numberElement.clear();
      expiryElement.clear();
      cvcElement.clear();
      form.submit();
    });
  });
};

window.addEventListener("turbo:load", pay);
window.addEventListener("turbo:render", pay);
