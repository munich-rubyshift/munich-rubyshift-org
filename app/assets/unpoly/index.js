// Import Unpoly (side effect: sets window.up)
import 'unpoly'
import 'unpoly/unpoly.css'

up.link.config.followSelectors.push('a[href]')
up.link.config.preloadSelectors.push('a[href]')
up.form.config.submitSelectors.push(['form'])
