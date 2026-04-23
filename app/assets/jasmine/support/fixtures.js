const fixturesContainer = () => {
  return document.getElementById('fixtures') || up.element.affix(document.body, '#fixtures')
}

afterEach(() => {
  up.destroy('#fixtures')
})

const appendFixtures = (...args) => {
  return up.element.affix(fixturesContainer(), ...args)
}
window.appendFixtures = appendFixtures

const loadPreviewScenario = (preview, scenario) => {
  const template = document.querySelector(`.test-cases template[data-component="${preview}"][data-scenario="${scenario}"]`)
  if (!template) {
    throw new Error(`Could not find template for [${preview} - ${scenario}]`)
  }
  const container = fixturesContainer()
  container.append(template.content.cloneNode(true))
  up.hello(container)
  return container
}
window.loadPreviewScenario = loadPreviewScenario
