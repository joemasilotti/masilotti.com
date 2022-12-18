function ready() {
  const buttons = document.querySelectorAll("#menu-close-button, #menu-open-button")
  const content = document.querySelector("#menu-content")

  buttons.forEach(button => {
    button.addEventListener("click", () => {
      content.classList.toggle("hidden")
    });
  });
}

document.addEventListener("DOMContentLoaded", ready)
