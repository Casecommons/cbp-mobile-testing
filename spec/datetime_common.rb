require_relative '../spec/spec_helper'


def get_today_date(delimiter='/') #expected param format: MM/DD/YYYY
  Time.now.strftime("%m#{delimiter}%d#{delimiter}%Y").to_s #reformat the object to mm/dd/yyyy
end

def get_today_date_without_leading_zero(delimiter='/') #expected param format: MM/DD/YYYY
  Time.now.strftime("%-m#{delimiter}%-d#{delimiter}%Y").to_s #reformat the object to mm/dd/yyyy
end

def return_today_date_as_mdyyyy
  return_date_as_mdyyyy(get_today_date)
end

def today_date_as_mmmddyyyy
  Time.now.strftime('%b %-d, %Y') #returns: Nov 2, 2015
end

def get_current_time #expected param format: HH:MM AM/PM
  Time.now.strftime('%I:%M %P').to_s
end

def get_today_date_as_format(outcome_format='%m/%d/%Y')
  Time.now.strftime(outcome_format).to_s #reformat the object to other format
end

def return_date_as_mmddyyyy(date) #expected param format: MM/DD/YYYY
  return_date_as_format(date, '%m/%d/%Y') #reformat the object to mm/dd/yyyy, with m and d containing 0 if less than 10
end

def return_date_as_mmddyy(date) #expected param format: MM/DD/YY
  return_date_as_format(date, '%m/%d/%y') #reformat the object to mm/dd/yy, with m and d containing 0 if less than 10
end

def return_date_as_mdyyyy(date) #expected param format: m/d/YYYY
  return_date_as_format(date, '%-m/%-d/%Y')
end

def return_date_as_format(date, outcome_format='%-m/%-d/%Y') #expected param format: m/d/YYYY
  input_format =  return_date_format(date)
  Date.strptime("#{date}", "#{input_format}").strftime("#{outcome_format}")
end

def return_full_date_time_as_format(date_time, outcome_format='%-m/%-d/%Y %I:%M %P')
  DateTime.strptime("#{date_time}", '%m/%d/%Y %l:%M %p').strftime("#{outcome_format}")
end

def return_format_datetime_from_inbound_xml(date_time)
  format = DateTime.strptime("#{date_time}", '%Y-%m-%dT%H:%M:%S%:z').strftime('%-m/%-d/%Y %I:%M %P %Z')
  format.gsub('-05:00', 'EST').gsub('-04:00', 'EDT')
end

def add_millisecond_to_datetime(date_time)
  DateTime.strptime("#{date_time}", '%Y-%m-%dT%H:%M:%S%:z').strftime('%Y-%m-%dT%H:%M:%S.%L%:z')
end

def return_date_as_mdyy(date)
  return_date_as_format(date, '%-m/%-d/%y')
end

def return_date_as_yyyy_mm_dd(date)
  return_date_as_format(date, '%Y-%m-%d')
end

def return_date_format(date)
  format = nil
  if date.match(/\d{4}-\d{2}-\d{2}/)
    format = '%Y-%m-%d'
  elsif date.match(/\d{1,2}\/\d{1,2}\/\d{4}/)
    format = '%m/%d/%Y'
  end
  format
end

def return_full_date_time(days_ago)
  Time.now - (days_ago * 86400)
end

def return_full_date_time_without_zone(days_ago=0)
  date_time = Time.now - (days_ago * 86400)
  date_time.strftime('%m%d%Y %H:%M')
end

def get_current_month_first_day
  get_first_day_of_a_month(get_today_date)
end

def get_first_day_of_a_month(date)
  return_date_as_format(date, '%-m/1/%Y')
end

def get_this_year_birthday(dob)
  Time.parse(dob).strftime('%m/%d/2015')
end

#pass in '9545804691' -> "(954) 580-4691"
def change_phone_number_format(phone_number)
  clear_number = phone_number.gsub(/[^0-9]/, '')
  "(#{clear_number[0..2]}) #{clear_number[3..5]}-#{clear_number[6..9]}"
end

# this function changes the date into the format we always use (m/d/y) and removes leading zeros in front of m and d
# function takes in a Date object or a string with m/d/y format
def remove_leading_zeros_from_date(date_to_convert)
  if date_to_convert.kind_of?(Date)
    Date.parse(date_to_convert.to_s).strftime('%-m/%-d/%Y')
  else
    date_to_convert.gsub!(/\s+/, '')
    return_date_as_format(date_to_convert, '%-m/%-d/%Y')
  end
end

def add_leading_zeros_to_date(date_to_convert)
  if date_to_convert.kind_of?(Date)
    Date.parse(date_to_convert.to_s).strftime('%m/%d/%Y')
  else
    date_to_convert.gsub!(/\s+/, '')
    return_date_as_format(date_to_convert, '%m/%d/%Y')
  end
end

#negative months to go to the past, positive months to go to the future
def offset_months_from_date(starting_date, months_to_offset) #starting_date should be in m/d/y format, months_to_offset can be positive or negative
  date = Date.strptime(starting_date, '%m/%d/%Y') #this converts the date string from m/d/y to a Date object (m-d-y)
  date = date >> months_to_offset
  remove_leading_zeros_from_date(date)
end

def offset_years_from_date(starting_date, years_to_offset) #starting_date should be in m/d/y format, months_to_offset can be positive or negative
  offset_months_from_date(starting_date, years_to_offset*12)
end

def get_date_from_datetime(datetime, date_format='%m/%d/%Y')
  datetime.strftime(date_format)
end

# :negative days to go to the past, positive days to go to the future:
# @param days_to_offset positive or negative integer
# @return mm/dd/yyyy
def offset_days_from_today(days_to_offset, date_format='%m/%d/%Y')
  new_date = Date.today + days_to_offset
  Date.parse(new_date.to_s).strftime(date_format)
end

def offset_days_from_today_without_leading_zero(days_to_offset, date_format='%m/%d/%Y')
  new_date = Date.today + days_to_offset
  remove_leading_zeros_from_date(Date.parse(new_date.to_s).strftime(date_format))
end

def offset_days_from_a_date(date, days_to_offset, date_format='%m/%d/%Y')
  date = Date.strptime(date, date_format)
  new_date = date + days_to_offset
  remove_leading_zeros_from_date(Date.parse(new_date.to_s).strftime(date_format))
end

def offset_days_from_today_remove_leading_zeros(days_to_offest)
  offset_days_from_today(days_to_offest, '%-m/%-d/%Y')
end

def calculate_dob_by_age(age, delimiter='/') #format: MM/DD/YYYY
  date = Time.now.to_date
  date = date << (age * 12).round
  month_string = date.month.to_s
  day_string = date.day.to_s
  month_string = "0#{month_string}" if date.month < 10
  day_string = "0#{day_string}" if date.day < 10
  dob = month_string + delimiter + day_string + delimiter + date.year.to_s
  #puts dob.to_s
  dob
end

def calculate_age_by_dob(dob)
  dob_object = Date.strptime("#{dob}", '%m/%d/%Y')
  ((Time.now.to_date - dob_object)/365.0).to_i
end

def sort_dates(dates, direction='ASC')
  dates.sort! do |x, y|
    a = x[/\d{1,2}\/\d{1,2}\/\d{4}/].nil? ? get_today_date : x
    b = y[/\d{1,2}\/\d{1,2}\/\d{4}/].nil? ? get_today_date : y
    DateTime.strptime(a, '%m/%d/%Y') <=> DateTime.strptime(b, '%m/%d/%Y')
  end
  dates.reverse! if direction == 'DESC'
  dates
end

def date_diff(date1, date2)
  month = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month) - (date2.day >= date1.day ? 0 : 1)
  month.divmod(12)
end

def calculate_months(date1, date2=get_today_date)
  date1 = Date::strptime(date1, '%m/%d/%Y')
  date2 = Date::strptime(date2, '%m/%d/%Y')
  date_diff(date1, date2)
end

def calculate_days(date1, date2=get_today_date)
  date1 = Date::strptime(date1, '%m/%d/%Y')
  date2 = Date::strptime(date2, '%m/%d/%Y')
  (date2 - date1).to_i
end

def compare_date?(date1, date2)
  date1 = get_today_date if date1 == 'present'
  date2 = get_today_date if date2 == 'present'
  Date::strptime(date1, '%m/%d/%Y') > Date::strptime(date2, '%m/%d/%Y')
end

def parse_date(date)
  DateTime.parse(date)
end

def get_format_date_from_datetime(datetime)
  datetime.strftime('%b %-d, %Y')
end

def generate_created_at
  DateTime.now - 1.0/24/60
end

def return_dob_by_given_age(age)
  offset_months_from_date(get_today_date, -((age.to_i*12))) #returns a date that will make the person 'age' and 2 months old
end