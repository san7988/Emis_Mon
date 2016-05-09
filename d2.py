import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev
import httplib, urllib

GPIO.setmode(GPIO.BCM)

pipes=[[0xE8, 0xE8, 0xF0, 0xF0, 0xE1],[0xF0, 0xF0, 0xF0, 0xF0, 0xE1]]

radio=  NRF24(GPIO, spidev.SpiDev())
radio.begin(0,17)

#32 is the max payload size : 32 bytes
radio.setPayloadSize(32)
radio.setChannel(0x76)
radio.setDataRate(NRF24.BR_1MBPS)
radio.setPALevel(NRF24.PA_MIN)
radio.setAutoAck(True)
radio.enableDynamicPayloads()
radio.enableAckPayload()

radio.openReadingPipe(1,pipes[1])
radio.printDetails()
radio.startListening()

while True:
  while not radio.available(0):
  #	print "sleeping"        
	time.sleep(1/100)

  rcvdMsg=[]
  radio.read(rcvdMsg, radio.getDynamicPayloadSize())
  # print(isinstance(rcvdMsg, (int, long)))
  print(rcvdMsg)
  print("rcvdddd {}".format(rcvdMsg))
  print("translating...")
  string=""

  for n in rcvdMsg:
    if n>32 and n<=126:
      string+=chr(n)
  print("decoded msg is {}".format(string))
  #params = urllib.urlencode({'field1': float(rcvdMsg), 'key':'14GN3ZU37NXWRU86'})
  #headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  #conn = httplib.HTTPConnection("api.thingspeak.com:80")
  #conn.request("POST", "/update", params, headers)
  #response = conn.getresponse()
  #print response.status, response.reason
  #data = response.read()
  #time.sleep(2)
