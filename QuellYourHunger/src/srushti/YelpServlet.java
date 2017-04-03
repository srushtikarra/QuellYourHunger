package srushti;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class YelpServlet
 */
@WebServlet("/YelpServlet")
public class YelpServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public YelpServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		
		//request all necessary info from form
		Map<String, String[]> map = request.getParameterMap();
		printMap(map, request);
		
		String keyword = request.getParameter("user_id");
		//Location
		String longitude = request.getParameter("longitude");
		String latitude = request.getParameter("latitude");
		String address = request.getParameter("userAddress");
		String locationType = request.getParameter("location");

		//Radius
		String distanceRadius = request.getParameter("distanceRadius");
		double radius = Integer.parseInt(distanceRadius)*1609.34;//meters

		//Most Popular
		String openNow = request.getParameter("openNow");
		String hotNew = request.getParameter("hotNew");
		String deal = request.getParameter("offerDeal");
		String cashback = request.getParameter("cashback");
		String delivery = request.getParameter("delivery");

		//Sort By
		String sort_by = request.getParameter("sorting");
		
		// Request parameters and other properties.
		//add parameters into array
		List<NameValuePair> params = new ArrayList<NameValuePair>();
				
		if(keyword != null && keyword.trim().length() > 0){
			params.add(new BasicNameValuePair("term", keyword));}
				
		if(locationType.equalsIgnoreCase("userLocation")){
			params.add(new BasicNameValuePair("location", address));}
		else{
			params.add(new BasicNameValuePair("latitude", latitude));
			params.add(new BasicNameValuePair("longitude", longitude));
					
			request.setAttribute("latitude", Double.parseDouble(latitude));
			request.setAttribute("longitude", Double.parseDouble(longitude));
			}
				
		if(radius > 0)
			params.add(new BasicNameValuePair("radius", ""+(int)radius));
				
		if(sort_by != null && sort_by.length() > 0)
			params.add(new BasicNameValuePair("sort_by", sort_by));

		//Most Popular
		if(openNow != null && openNow.length() > 0)
			params.add(new BasicNameValuePair("open_now", openNow));
				
		//place attributes in array
		ArrayList attrs = new ArrayList();		
		if(hotNew != null && hotNew.length() > 0)
			attrs.add(hotNew);
		if(deal != null && deal.length() > 0)
			attrs.add(deal);
		if(cashback != null && cashback.length() > 0)
			attrs.add(cashback);	
		if(attrs.size() > 0){
			String csv = String.join(",", attrs);
			params.add(new BasicNameValuePair("attributes", csv));
			}
		
		//create new class, authenticate it
		YelpApiAuthenticate yelp1 = new YelpApiAuthenticate();
		yelp1.authenticate();
		
		//if there's an error getting businesses
		//otherwise continue with making the array of businesses
		String jsonString = yelp1.search(params);
		if(yelp1.responseCode != 200){
			request.setAttribute("businesses", null);
		}
		else{
			JSONObject jobj = new JSONObject(jsonString);
			System.out.println(jobj.toString());
			JSONArray jsonArray =  jobj.getJSONArray("businesses");	
			request.setAttribute("businesses", jsonArray);
		}
		
		RequestDispatcher rd =  request.getRequestDispatcher("/find.jsp");
		rd.forward(request, response);

	}
	
	//prints map on page
	public static void printMap(Map mp, HttpServletRequest request) {
	    Iterator it = mp.entrySet().iterator();
	    while (it.hasNext()) {
	        Map.Entry pair = (Map.Entry)it.next();
	        String[] val = (String[]) pair.getValue();
	        System.out.println(pair.getKey() + " = " + Arrays.toString(val));
	        request.setAttribute((String) pair.getKey(), request.getParameter((String) pair.getKey()));
	    }
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	
	

}
