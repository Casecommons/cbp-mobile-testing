require_relative '../spec/spec_helper'
def generate_special_characters(length = 4, complexity = 4)
  subsets = [('!'..'/'), (':'..'?'), ('µ'..'ö')]
  chars = subsets[0..complexity].map {|subset| subset.to_a}.flatten
  chars.sample(length).join
end

def return_random_content(type='first_name')
  case type
  when 'first_name'
    loop do
      temp = Faker::Name.first_name.delete("'")
      if /^([A-Za-z]{1,2})$/.match(temp).nil?
        return temp
      end
    end
  when 'last_name'
    "Q#{[*'AA'..'ZZ'].sample}#{Faker::Name.last_name.delete("'")}"
  when 'resource_name'
    "Q#{[*'AA'..'ZZ'].sample}#{Faker::Company.name.delete("'").delete(',').gsub('-', ' ')}"
  when 'full_name'
    "#{return_random_content('first_name')} #{return_random_content('last_name')}"
  when 'word'
    "Q#{[*'AA'..'ZZ'].sample}#{Faker::Lorem.word}"
  when 'sentence'
    Faker::Lorem.sentence(3)
  when 'paragraph'
    Faker::Lorem.paragraph(3)
  when 'address1'
    "#{Faker::Address.street_address}"
  when 'city'
    Faker::Address.city
  when 'street'
    Faker::Address.street_name
  when 'email'
    Faker::Internet.safe_email
  when 'special_characters'
    generate_special_characters
  else
  end
end

def return_random_number(type)
  Faker::Config.locale = 'en-US'
  case type
  when 'phone'
    "#{Faker::PhoneNumber.area_code}#{Faker::PhoneNumber.exchange_code}#{Faker::PhoneNumber.subscriber_number}"
  when 'phone with symbols'
    "(#{Faker::PhoneNumber.area_code}) #{Faker::PhoneNumber.exchange_code}-#{Faker::PhoneNumber.subscriber_number}"
  when 'phone with ext'
    "(#{Faker::PhoneNumber.area_code}) #{Faker::PhoneNumber.exchange_code}-#{Faker::PhoneNumber.subscriber_number} x#{Faker::PhoneNumber.exchange_code}"
  when 'phone exchange code'
    Faker::PhoneNumber.exchange_code
  when 'id'
    "#{(100000000000000 + Random.rand(890000000000009))}"
  when 'ssn'
    rand(100000000..999999999).to_s.insert(3, '-').insert(6, '-')
  when 'zip'
    Faker::Address.zip_code
  when 'fein'
    "#{10 + Random.rand(89)}-#{1000000 + Random.rand(8999999)}"
  when 'dob'
    return_date_as_mmddyyyy(return_dob_by_given_age(1+rand(14))).to_s
  when 'dob_xml'
    return_date_as_yyyy_mm_dd(return_dob_by_given_age(1+rand(14))).to_s
  when 'msg_id'
    SecureRandom.hex(16).to_s
  when 'short'
    "#{10000 + Random.rand(89999)}"
  when 'event_id'
    "#{Time.now.to_i*100 + Random.rand(99) - Random.rand(99)}"
  end
end