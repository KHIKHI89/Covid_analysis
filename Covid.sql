select * from new_one..human_resources

UPDATE new_one..human_resources
set birthdate = case 
     when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%d-%m')
	 when birthdate like  '%-%' then date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%d-%m')
	 else NULL
end 