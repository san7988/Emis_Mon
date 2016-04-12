#Pushing data to Thingspeak
# python
import httplib, urllib, random, time
while True:
	params = urllib.urlencode({'field1': random.randrange(10,50), 'key':'14GN3ZU37NXWRU86'})
	headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
	conn = httplib.HTTPConnection("api.thingspeak.com:80")
	conn.request("POST", "/update", params, headers)
	response = conn.getresponse()
	print response.status, response.reason
	data = response.read()
	time.sleep(1)
conn.close()
