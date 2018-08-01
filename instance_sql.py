import json
def json_return():
	with open('sql_inst.json') as f:
		data=json.load(f)
	return data['ipAddresses'][0]['ipAddress']
json_return()