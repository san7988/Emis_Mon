package com.test;
import com.twilio.sdk.TwilioRestClient;
import com.twilio.sdk.TwilioRestException;
import com.twilio.sdk.resource.factory.MessageFactory;
import com.twilio.sdk.resource.instance.Message;
import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
 
import java.util.ArrayList;
import java.util.List;
 
public class example {
 
  // Find your Account Sid and Token at twilio.com/user/account
  public static final String ACCOUNT_SID = "ACb76f2528efdd9bfa02bfa477d960607e";
  public static final String AUTH_TOKEN = "13aa9f6af7446eb9ff1324948806d5aa";
  public static boolean toSend=true;
 
  public void sendSMS(String msg) throws TwilioRestException {
    float f=Float.parseFloat(msg);
    TwilioRestClient client = new TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN);
    //System.out.println("inside sendSMS mean is :"+f);
    // Build a filter for the MessageList
    if(toSend){
    	System.out.println("inside sendSMS");
    	    List<NameValuePair> params = new ArrayList<NameValuePair>();
    params.add(new BasicNameValuePair("Body", "Get your vehicle checked. Mean is "+f));
    params.add(new BasicNameValuePair("To", "+919047553911"));
    params.add(new BasicNameValuePair("From", "+12566614948"));
    MessageFactory messageFactory = client.getAccount().getMessageFactory();
    Message message;
	
		message = messageFactory.create(params);
		System.out.println(message.getSid());
	   
    example.toSend=false;
  }

  }
}