require 'appium_lib'
require 'appom'

appium_lib_options = {
    server_url: 'http://0.0.0.0:4723/wd/hub'
}

ios_caps = {
    automationName: 'XCUITest',
    platformName: 'iOS',
    platformVersion: '13.2',
    deviceName: 'iPad Pro (12.9-inch) (3rd generation)',
    app: '~/workspace/CasebookInspect/ios/build/CasebookEvaluate/Build/Products/Debug-iphonesimulator/CasebookEvaluate.app',
    newCommandTimeout: 3000,
    safariIgnoreFraudWarning: true,
    clearSystemFiles: true,
    sendKeyStrategy: 'setValue',
    noReset: true,
    fullReset: false,
    # wdaLocalPort: 8200
}

Appom.register_driver do
  options = {
      appium_lib: appium_lib_options,
      caps: ios_caps
  }
  Appium::Driver.new(options, false)
end

Appom.configure do |config|
  config.max_wait_time = 30
end





