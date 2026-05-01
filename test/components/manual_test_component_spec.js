describe('ManualTestComponent', () => {
  let heading, paragraph

  beforeEach(() => {
    const container = loadPreviewScenario('manual_test', 'with_multiple_top_level_tags')
    heading = container.querySelector('h1')
    paragraph = container.querySelector('p')
  })

  it('loads both tags correctly', () => {
    expect(heading).toContainText('Heading')
    expect(paragraph).toContainText('Paragraph')
  })
})
