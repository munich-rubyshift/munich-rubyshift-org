up.compiler('[data-compiler="counter"]', (element, { initialValue }) => {
  const display = element.querySelector('[data-element="counter:value"]')
  const decrementButton = element.querySelector('[data-element="counter:decrement"]')
  const incrementButton = element.querySelector('[data-element="counter:increment"]')

  let value = Number(initialValue || 0)

  const updateDisplay = () => {
    display.textContent = value
  }

  const changeValue = (delta) => {
    value += delta
    updateDisplay()
  }

  const destructors = [
    up.on(decrementButton, 'click', () => changeValue(-1)),
    up.on(incrementButton, 'click', () => changeValue(1))
  ]

  updateDisplay()
  return destructors
})
