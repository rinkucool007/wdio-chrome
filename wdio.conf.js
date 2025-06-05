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
  services: [], // Explicitly disable all services, including 'chromedriver'
  // Specify ChromeDriver custom path
  chromedriverCustomPath: process.env.CHROMEDRIVER_PATH || '/usr/local/bin/chromedriver',
  logLevel: 'info',
  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: {
    ui: 'bdd',
    timeout: 60000
  },
  // Debug ChromeDriver path in onPrepare hook
  onPrepare: function (config, capabilities) {
    const path = require('path');
    const fs = require('fs');
    const driverPath = process.env.CHROMEDRIVER_PATH || '/usr/local/bin/chromedriver';
    console.log('ChromeDriver path:', driverPath);
    console.log('File exists:', fs.existsSync(driverPath));
  }
};
