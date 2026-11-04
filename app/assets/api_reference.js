import SwaggerUIBundle from 'swagger-ui-dist/swagger-ui-es-bundle.js'
import SwaggerUIStandalonePreset from 'swagger-ui-dist/swagger-ui-standalone-preset.js'
import 'swagger-ui-dist/swagger-ui.css'

SwaggerUIBundle({
  dom_id: '#api-reference',
  urls: [{ name: 'v1', url: '/api/v1/schema.yaml' }],
  presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
  layout: 'StandaloneLayout',
  validatorUrl: null,
})
