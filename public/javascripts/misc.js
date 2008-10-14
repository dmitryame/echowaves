function pageScroll() {
  window.scrollBy(0,50000); // horizontal and vertical scroll increments
}

  // try to focus an input field, if we can find it
function focusInput(inputId) {
  if ($(inputId)) {
    $(inputId).focus();
  }
}
