describe('CounterComponent', () => {
  let component, decrement, increment, value

  beforeEach(() => {
    const container = loadPreviewScenario('counter', 'zero')
    component = container.querySelector('.counter')
    decrement = component.querySelector('[data-element="counter:decrement"]')
    increment = component.querySelector('[data-element="counter:increment"]')
    value = component.querySelector('[data-element="counter:value"]')
  })

  it('shows the initial value', () => {
    expect(value).toContainText('0')
  })

  it('increments the counter when the increment button is clicked', () => {
    increment.click()
    expect(value).toContainText('1')
  })

  it('decrements the counter when the decrement button is clicked', () => {
    decrement.click()
    expect(value).toContainText('-1')
  })
})
