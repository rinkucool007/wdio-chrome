export const config = {
  runner: 'local',
  specs: ['./test/specs/**/*.js'],
  capabilities: [{
    browserName: 'chrome',
    'goog:chromeOptions': {
      binary: '/usr/bin/google-chrome', // Path to Chrome binary in Oracle Linux
      args: [
        '--headless', // Run in headless mode for Docker
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu'
      ]
    }
  }],
  services: [], // Do not include 'chromedriver' service
  // Specify ChromeDriver path explicitly
  chromeDriver: {
    binary: process.env.CHROMEDRIVER_PATH || '/usr/local/bin/chromedriver'
  },
  logLevel: 'info',
  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: {
    ui: 'bdd',
    timeout: 60000
  }
};
