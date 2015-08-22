local app_info = {app_id = 12345, app_name = 'liangtao01'};
if type(app_info) == 'table' and next(app_info) then
	print(app_info.app_id);
end