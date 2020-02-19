require_relative '../spec/spec_helper'
def post_to_cognito_api(request_body_xml)
  url = URI.parse('https://cognito-idp.us-east-1.amazonaws.com/')

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url.path)
  request['Content-Type'] = 'application/x-amz-json-1.1'
  request['X-Amz-Target'] = 'AWSCognitoIdentityProviderService.InitiateAuth'

  xml = JSON.generate(request_body_xml)
  request.body = xml

  start_time = Time.now
  begin
    response_raw = http.request(request)
  rescue Exception => e
    sleep 1
    puts e
    retry until Time.now - start_time > 90
  end

  response = JSON.parse(response_raw.body)
  response
end

def get_id_token(env)
  env_path = __dir__ + '/environment.json'
  file = File.read(env_path)
  env_data = JSON.parse(file)

  client_id = env_data[env]['client_id']
  refresh_token = env_data[env]['refresh_token']

  request_body_xml = { AuthParameters: { REFRESH_TOKEN: refresh_token },
                       AuthFlow: 'REFRESH_TOKEN_AUTH', ClientId: client_id }
  id_token = post_to_cognito_api(request_body_xml)['AuthenticationResult']['IdToken']

  id_token
end

def post_to_api(url, request_body_xml, token)
  url = URI.parse(url)

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(url.path)
  request['Content-Type'] = 'application/vnd.api+json'
  request['Accept'] = 'application/vnd.api+json'
  request['Accept-Version'] = 'v0'
  request['Authorization'] = token

  xml = JSON.generate(request_body_xml)
  request.body = xml

  start_time = Time.now
  begin
    response_raw = https.request(request)
  rescue Exception => e
    sleep 1
    puts e
    retry until Time.now - start_time > 90
  end

  response = JSON.parse(response_raw.body)
  puts "response: #{response}"
  response
end

def delete_by_id(env, app_endpoint, id)
  id_token = get_id_token(env)
  token = "Bearer #{id_token}"

  env_path = __dir__ + '/environment.json'
  file = File.read(env_path)
  env_data = JSON.parse(file)[env]
  url = env_data['url']

  url = URI.parse("#{url}/#{app_endpoint}/#{id}")
  puts "deleting: #{url}"

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Delete.new(url.path)
  request['Content-Type'] = 'application/vnd.api+json'
  request['Accept'] = 'application/vnd.api+json'
  request['Accept-Version'] = 'v0'
  request['Authorization'] = token

  start_time = Time.now
  begin
    response_raw = https.request(request)
  rescue Exception => e
    sleep 1
    puts e
    retry until Time.now - start_time > 90
  end

  if  response_raw.code == '204'
    puts "delete successfully"
  else
    puts "error: #{JSON.parse(response_raw.body)}"
  end
end

def patch_by_id(url, id, request_body_xml, token)
  url = URI.parse("#{url}/#{id}")

  request = Net::HTTP::Patch.new(url.path)
  request['Content-Type'] = 'application/vnd.api+json'
  request['Accept'] = 'application/vnd.api+json'
  request['Accept-Version'] = 'v0'
  request['Authorization'] = token

  xml = JSON.generate(request_body_xml)
  request.body = xml

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  start_time = Time.now
  begin
    response_raw = https.request(request)
  rescue Exception => e
    sleep 1
    puts e
    retry until Time.now - start_time > 90
  end

  response = JSON.parse(response_raw.body)
  puts "response: #{response}"

  if  response_raw.code == '200'
    puts "patch successfully"
  else
    puts "error: #{JSON.parse(response_raw.body)}"
  end
end

def seed_evaluate(env)
  id_token = get_id_token(env)
  token = "Bearer #{id_token}"

  env_path = __dir__ + '/environment.json'
  file = File.read(env_path)
  env_data = JSON.parse(file)[env]
  url = env_data['url']

  location_xml = { data: { type: 'locations',
                           attributes: { address1: Faker::Address.street_address, address2:'Apt G', city: Faker::Address.city,
                                         state: Faker::Address.state, zip_code: Faker::Address.zip_code, country: Faker::Address.country,
                                         latitude: Faker::Address.latitude, longitude: Faker::Address.longitude
                            } } }
  location_id = post_to_api("#{url}/providers/locations", location_xml, token)['data']['id']

  assign_xml = { data: { type: 'assignees',
                         attributes: { user_id:  env_data['user_id'] } } }
  assignee_id = post_to_api("#{url}/providers/assignees", assign_xml, token)['data']['id']

  provider_xml = { data: { type: 'providers',
                           attributes: { name: Faker::Company.name },
                           relationships: {
                               assignee: { data: { type: 'assignees', id: assignee_id } },
                               facility_location: { data: { type: 'locations', id: location_id } },
                               provider_type: { data: { type: 'provider_types', id: env_data['provider_types_id'] } },
                               provider_subtype: { data: { type: 'facility_types', id: env_data['provider_subtype_id'] } },
                           } } }
  provider = post_to_api("#{url}/providers/providers", provider_xml, token)['data']

  service_xml = { data: { type: 'services',
                           attributes: { capacity_usage: 4, max_capacity: 10 },
                           relationships: {
                               provider: { data: { type: 'providers', id: provider['id'] } },
                               service_type: { data: { type: 'service_types', id: env_data['service_types_id'] } },
                           } } }
  post_to_api("#{url}/providers/services", service_xml, token)

  form_submission_xml = { data: { type: 'form_submissions',
                          attributes: { form_version_id: env_data['form_version_id'], completed: false } } }
  form_submission_id = post_to_api("#{url}/providers/form_submissions", form_submission_xml, token)['data']['id']

  provider_form_submission_xml = { data: { type: 'provider_form_submissions',
                                           relationships: {
                                               provider: { data: { type: 'providers', id: provider['id'] } },
                                               form_submission: { data: { type: 'form_submissions', id: form_submission_id } }
                                           } } }
  post_to_api("#{url}/providers/provider_form_submissions", provider_form_submission_xml, token)

  visit_xml = { data: { type: 'visits',
                        attributes: { start_at: return_date_as_yyyy_mm_dd(offset_days_from_today(10)), notes: 'visit notes' },
                        relationships: {
                            contact_type: { data: { type: 'contact_types', id: env_data['contact_type_id'] } },
                            provider: { data: { type: 'providers', id: provider['id'] } },
                            form_submission: { data: { type: 'form_submissions', id: form_submission_id } }
                        } } }
  visit_id = post_to_api("#{url}/providers/visits", visit_xml, token)['data']['id']

  license_xml = { data: { type: 'licenses',
                        attributes: { started_on: return_date_as_yyyy_mm_dd(offset_months_from_date(get_today_date, -2)),
                                      ended_on: return_date_as_yyyy_mm_dd(offset_days_from_today(20)) },
                        relationships: {
                            provider: { data: { type: 'providers', id: provider['id'] } },
                            license_type: { data: { type: 'license_types', id: env_data['license_types_id'] } },
                            license_status: { data: { type: 'license_status', id: env_data['license_status_id'] } }
                        } } }
  license_id = post_to_api("#{url}/providers/licenses", license_xml, token)['data']['id']

  license_conditions_xml = { data: { type: 'license_conditions',
                                     attributes: { min_age: 5, max_age: 16, other_condition: 'no other conditions' },
                                     relationships: {
                                         license: { data: { type: 'licenses', id: license_id } },
                                         gender: { data: { type: 'genders', id: env_data['gender_id'] } }
                          } } }
  post_to_api("#{url}/providers/license_conditions", license_conditions_xml, token)

  providers_patch_xml = { data: { type: 'providers',
                                     attributes: { published: true },
                                     relationships: {
                                         license: { data: { type: 'licenses', id: license_id } },
                                         visits: { data: { type: 'visits', id: visit_id } }
                                     } } }
  patch_by_id("#{url}/providers/providers", provider['id'], providers_patch_xml, token)
  #
  # admin_xml = { data: { type: 'form_application_categories',
  #                       attributes: { provider_type_id: env_data['provider_types_id'], license_status_id: env_data['license_status_id'] },
  #                       relationships: {
  #                           form: { data: { type: 'forms', id: env_data['form_id'] } }
  #                       } } }
  # post_to_api("#{url}/admin/form_application_categories", admin_xml, token)

  { provider_id: provider['id'], provider_name: provider['attributes']['name']}
end