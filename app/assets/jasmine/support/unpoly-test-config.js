// Make test faster and less flaky
up.motion.config.enabled = false

// No link and form handling while on Jasmine runner page
up.link.config.followSelectors = []
up.link.config.preloadSelectors = []
up.form.config.submitSelectors = []
