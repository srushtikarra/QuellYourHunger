package srushti;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicHeader;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;

public class YelpApiAuthenticate {
	
	public static String YELP_APP_ID = "cFPCMGMldB-NKDn7EvS7lA";
	public static String YELP_APP_SECRET = "gAiYXRKpWU4Ui5PwbF10lj0KPHh1txlg9xed1W34zBSjScJATvE3q2H0BdqEYvmJ";
	public static String YELP_ACCESS_TOKEN = "";
	
	
	public static String YELP_URL_AUTHENTICATE = "https://api.yelp.com/oauth2/token";
	public static String YELP_URL_SEARCH = "https://api.yelp.com/v3/businesses/search"; 
	public static int responseCode = 0;
	
	
	public static void authenticate()
	{
		// Request parameters and other properties.
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("grant_type", "client_credentials"));
		params.add(new BasicNameValuePair("client_id", YELP_APP_ID));
		params.add(new BasicNameValuePair("client_secret", YELP_APP_SECRET));
		
		ArrayList<Header> headers = new ArrayList<Header>();
		headers.add(new BasicHeader("Content-Type", "application/x-www-form-urlencoded"));

		JSONObject reponseObj = processPOSTRequest(YELP_URL_AUTHENTICATE, params, headers);
		
		YELP_ACCESS_TOKEN = reponseObj.getString("access_token");
		
		System.err.println("YELP_TOKEN->"+YELP_ACCESS_TOKEN);
	}
	
	public static String search(List<NameValuePair> params)
	{

		ArrayList<Header> headers = new ArrayList<Header>();
		//headers.add(new BasicHeader("Content-Type", "application/x-www-form-urlencoded"));
		headers.add(new BasicHeader("Authorization", "Bearer "+YELP_ACCESS_TOKEN));

		String reponseObj = processGETRequest(YELP_URL_SEARCH, params, headers);
		
		return reponseObj;
	}

	public static JSONObject processPOSTRequest(String url, List<NameValuePair> params, ArrayList<Header> headers)
	{
		String responseStr = "";
		HttpClient httpClient = HttpClientBuilder.create().build();
		
		HttpPost httpPost = new HttpPost(url);
		httpPost.setHeaders((Header[]) headers.toArray(new Header[headers.size()]));
		
		//application/x-www-form-urlencoded
		try {
		    httpPost.setEntity(new UrlEncodedFormEntity(params, "UTF-8"));
		} catch (UnsupportedEncodingException e) {
		    // writing error to Log
		    e.printStackTrace();
		}
		/*
		 * Execute the HTTP Request
		 */
		try {
		    HttpResponse response = httpClient.execute(httpPost);
		    HttpEntity respEntity = response.getEntity();

		    if (respEntity != null) {
		        // EntityUtils to get the response content
		        responseStr =  EntityUtils.toString(respEntity);
		        System.err.println("Response: "+responseStr);
		    }
		} catch (ClientProtocolException e) {
		    // writing exception to log
		    e.printStackTrace();
		} catch (IOException e) {
		    // writing exception to log
		    e.printStackTrace();
		}
		
		return 	new JSONObject(responseStr);

	}
	
	public static String processGETRequest(String url, List<NameValuePair> params, ArrayList<Header> headers)
	{
		StringBuffer result = new StringBuffer();
		try {
			HttpClient client = HttpClientBuilder.create().build();
			HttpGet request = new HttpGet(url);

			// add request header
			request.setHeaders((Header[]) headers.toArray(new Header[headers.size()]));
			
			//request.setHeader("Authorization", "Bearer "+YELP_ACCESS_TOKEN);
			
			URI uri = new URIBuilder(request.getURI()).addParameters(params).build();
            request.setURI(uri);
            
            Iterator<NameValuePair> i = params.iterator();
            while(i.hasNext()){
            	NameValuePair nvp = i.next();
                System.out.println(nvp.getName() + " = " + nvp.getValue());
            }

            
			HttpResponse response = client.execute(request);
			responseCode = response.getStatusLine().getStatusCode();
			System.out.println("Response Code : "
			                + response.getStatusLine().getStatusCode());

			BufferedReader rd = new BufferedReader(
				new InputStreamReader(response.getEntity().getContent()));

			String responseStr = "";
			
			while ((responseStr = rd.readLine()) != null) {
				result.append(responseStr);
				System.err.println(responseStr);
			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return 	result.toString();
		
	}
	
	public static void main(String[] args) {
		
		YelpApiAuthenticate yaa = new YelpApiAuthenticate();
		yaa.authenticate();
		
		String longitude = "-74.41738769999999";
		String latitude = "40.9245036";
		String zipCode = "07082";
		String distance = "10";
		String locationType = "zip";//zip - location

		// Request parameters and other properties.
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("term", "delis"));
		params.add(new BasicNameValuePair("sort_by", "rating"));

		if(locationType.equalsIgnoreCase("zip"))
		{
			params.add(new BasicNameValuePair("location", zipCode));
		}
		else
		{
			params.add(new BasicNameValuePair("latitude", latitude));
			params.add(new BasicNameValuePair("longitude", longitude));
			
		}


		yaa.search(params);
	}	
}
