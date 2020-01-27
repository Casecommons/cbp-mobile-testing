require 'rubygems'
require 'appium_lib'
require 'uri'
require 'net/http'
require 'json'
require_relative 'constants.rb'

def start_appium_driver(caps_hsh={})
  if caps_hsh.nil?
    desired_capabilities = { caps: CAPS_ORIGINAL }
  else
    desired_capabilities = { caps: CAPS_ORIGINAL.merge(caps_hsh) }
  end

  driver = Appium::Driver.new(desired_capabilities, true)
  driver.start_driver
  Appium.promote_appium_methods RSpec::Core::ExampleGroup

  driver
end

def login_as(user, app_name='Mobile', login=true )
  wait { text_exact(app_name) }
  find_exact('LoginButton').click

  wait { text_exact('Platform') }
  find_element(:id, 'Select an identity provider').click

  wait { text_exact('Case Commons (Acceptance)') }

  env = find_element(:name, 'Case Commons (Acceptance)')
  env.click

  button('Sign In').click
  wait { find_exact('Casebook logo') }

  user_name_attribute = get_attribute('Username','value')
  if user_name_attribute.eql?('Username') == false
    clear_field_by_select_all_and_delete('Username')
  end

  type_in_field('Username', user[:email])
  type_in_field('Password', user[:password])
  # driver.hide_keyboard if is_keyboard_shown

  if login
    button('Sign In').click

    if element_exist?('Allow', :name)
      alert(action:'accept', button_label: 'Allow')
    end

    wait { text(user[:name])}
  end
end

def logout
  #click on drawer menu
  find_exact('cb Track NetworkIcon').click
  wait { find_exact('AppNavigationSrawer')}

  wait_for_element_and_click( :id, 'log out')
  alert(action:'accept', button_label: 'Log out')
  wait { text_exact('Mobile') }
end

def clear_fields(accessibility_id_arry)
  [accessibility_id_arry].flatten.compact.each do |accessibility_id|
    element = find_element(:accessibility_id, accessibility_id)
    element.clear
  end
end

def type_in_field(id, key, selector_type=:accessibility_id)
  element = find_element(selector_type, id)
  element.send_keys(key)
end

def clear_field_by_select_all_and_delete(accessibility_id)
  field = find_element(:accessibility_id, accessibility_id)
  field.click

  touch_and_hold(element:field)
  wait { exists { find_element(:accessibility_id, 'Select All') }}
  find_element(:accessibility_id, 'Select All').click

  field.send_keys :backspace
end

def hide_keyboard(driver)
  if driver.is_keyboard_shown
    driver.hide_keyboard
  end
end

def element_visible?(selector_id, selector_type=:accessibility_id)
  element = find_element(selector_type, selector_id).displayed?
  element.nil? ? false : true
end

def element_exist?(selector_id, selector_type=:accessibility_id)
  begin
    find_element(selector_type, selector_id)
    true
  rescue
    false
  end
end

def check_checkbox(selector)
  starting = Time.now

  until  find_element(:name, selector).selected?
    find_element(:name, selector).click
    break if Time.now - starting > 60
  end
end

def get_attribute(selector, attribute)
  element = find_element(:name, selector)
  attribute = element.attribute(attribute)
  attribute
end

def wait_for_element_and_click(selector_type, selector)
  wait { find_element(selector_type, selector).displayed? }
  find_element(selector_type, selector).click
end

def wait_title_bar_elements(title_bar_text, screen)
  wait { find_exact(title_bar_text) }

  network_icon = element_exist?('NetworkIcon', :name)
  expect(network_icon).to be true

  case screen
  when 'form'
    back_arrow = element_exist?('FormScreenBackButton', :name)
    expect(back_arrow).to be true

    save_button = element_exist?('FormSaveButton', :name)
    expect(save_button).to be true
  when 'dashboard'
    #drawer menu element here
  else
    puts "please put in the correct screen name"
  end
end

def dismiss_yellow_box
 if element_exist?('Dismiss All', :name)
    element = find_exact('Dismiss All')
    element.click

    wait {!exists {element}}
  end
end

def click_two_tier_element(tier1_element_name, tier2_element_name)
  tier_1_ele_1 = find_element(:name, tier1_element_name)
  tier_1_ele_2 = tier_1_ele_1.find_element(:name, tier2_element_name)
  tier_1_ele_2.find_element(:name, tier2_element_name).click
end

def scroll_down_and_type(element_id, key)
  scroll(direction: 'down', name: element_id)
  type_in_field(element_id, key)
  dismiss_yellow_box
end

def select_date_from_pickerwheel(date_picker_text, month, date)
  date_picker = find_exact(date_picker_text).find_element(:class_name, 'XCUIElementTypeTextField')
  date_picker.click
  wait { find_elements(:class_name, 'XCUIElementTypePickerWheel')}

  date_picker = find_elements(:class_name, 'XCUIElementTypePickerWheel')
  date_picker[0].send_keys(month)
  date_picker[1].send_keys(date)

  double_tap(x: 250, y: 850)
  wait {!exists {date_picker}}
end

def go_to_form(form_status)
  # form_status: Start, Resume
  find_exact('DashboardListViewMenu').click
  wait { find_exact("#{form_status} inspection").click }
  wait { text_exact('Name of provider') }
end