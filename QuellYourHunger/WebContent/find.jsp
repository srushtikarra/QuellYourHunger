<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONArray"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Quell Your Hunger</title>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3&sensor=false&language=en&key=AIzaSyDbY4HDOa58pDQJPHXbsjGHVclwQeQojnQ"> </script>
<script >

//global variables
var lat = "", longt = "", markerLocations,  map;

//if link is clicked, table will switch between visible and not
function toggleFilter()
{
	var show = document.getElementById('id_filters');
	if(show.style.display === 'none')
		show.style.display = 'block';
	else show.style.display = 'none';
}

//bw 2 radio btns, if one is selected, disable use of other option
function disableOther(item)
{
	if(item.value == "userLocation")
		document.getElementbyId("id_address").readOnly = false;
	else{
	 document.getElementbyId("id_address").readOnly = true;
	 getGeoLocation();
	 }
}

//func that is initially called
function updateLocationMarkers()
{
	if(document.getElementById("id_markers") == null || document.getElementById("id_markers").value == '')
		setMyGeoLocation();
	else setBusinessMarkers();	
}

//for first time use, gets geo location from the browser
//won't work w/ chrome, firefox; works on safari
function setMyGeoLocation()
{
	if(navigator.geolocation)
		navigator.geolocation.getCurrentPosition(showMyPosition, showPosError);
	else document.getElementById("basic-map").innerHTML = "Geolocation is not supported by your browser.";
}

//if browser gets location, uses global variables and adds to markersLocations array
function showMyPosition(position)
{
	lat = position.coords.latitude;
    longt = position.coords.longitude;
    
    document.getElementById("latitude").value=position.coords.latitude;
    document.getElementById("longitude").value=position.coords.longitude;

 	markerLocations = [ ['My Location', lat,longt, 1]	];
    initialize();
    addMarkers();
}
//if browser doesn't give location, do error analysis and print
function showPosError(error) 
{
    switch(error.code) 
    {
        case error.PERMISSION_DENIED:
        	document.getElementById("basic-map").innerHTML = "User denied the request for Geolocation."
            break;
        case error.POSITION_UNAVAILABLE:
        	document.getElementById("basic-map").innerHTML = "Location information is unavailable."
            break;
        case error.TIMEOUT:
        	document.getElementById("basic-map").innerHTML = "The request to get user location timed out."
            break;
        case error.UNKNOWN_ERROR:
        	document.getElementById("basic-map").innerHTML = "An unknown error occurred."
            break;
    }
}

//goes through markerLocations array to output businnesses' location markers on map
function setBusinessMarkers()
{
	var input = document.getElementById("id_markers").value;
    input = input.replace(/'/g, "&apos;");
    		
    try {markerLocations = eval(input);} 
    catch(e) {alert(e.stack);}
    	
    initialize();
    addMarkers();
}

//puts up map on page
//after search, centered on lat/longt of first business location
function initialize()
{
    try {
    	if(markerLocations.length >= 2)
    		{
	        lat = markerLocations[1][1];
	    	longt = markerLocations[1][2];
    		}
		map = new google.maps.Map(document.getElementById('map_canvas'), {
		   zoom: 11,
		   center: new google.maps.LatLng(lat, longt),
		   mapTypeId: google.maps.MapTypeId.ROADMAP
		   });
    	} 
    catch(e) {alert(e.stack);}
 
}

//for each in markerLocations array, adds marker to map
var markerObjects = [];
function addMarkers()
{
	//alert("addMarkers");
	var marker, i, infowindow = new google.maps.InfoWindow();
	for (i = 0; i < markerLocations.length; i++) 
	{  
		var lbl = ""+i;
	    marker = new google.maps.Marker({
	        position: new google.maps.LatLng(markerLocations[i][1], markerLocations[i][2]),
	        map: map,
	        label:lbl
	    });
	    google.maps.event.addListener(marker, 'click', (function(marker, i) {
	        return function() {
	            infowindow.setContent(markerLocations[i][0]);
	            infowindow.open(map, marker);
	        }
	    })(marker, i));
	    
		markerObjects.push(marker);
	    
	}
}

//takes input from form and validates it
function validation()
{
	var location = document.getElementsByName("location");
	var locationValue = "";
	for(var i = 0; i< location.length; i++){
		if(location[i].checked){
			locationValue = location[i].value;
		}
	}

	//alert(locationValue);	
	if(locationValue == "userLocation" && document.form1.id_address.value == ""){
		alert("Please enter combination of address, neighborhood, city, state or zip." );
		document.getElementById("id_address").focus();
	    return false;
	}
	
	if(locationValue == "geoLocation" && (document.form1.latitude.value == "" || document.form1.longitude.value == "")){
		alert( "Failed to retreive geo location or latitude and longitude, Please use address" );
		document.getElementById("id_geo").checked = false;
		document.getElementById("id_user").checked = true;
		document.getElementById("id_address").focus();
	    return false;
	}
	
	return true;
}

//when div in result table is clicked, the marker will be triggered to show its info
function showInfoWindow(markerId)
{
	//alert(markerId);
	google.maps.event.trigger(markerObjects[markerId], 'click');
}
</script>
</head>

<!-- creating table for overall layout -->
<body bgcolor="#CCCCFF" onload="updateLocationMarkers()">
<form name="form1" action = "YelpServlet" onsubmit="return validation();">
<!-- create hidden inputs for lat and long -->
<input type="hidden" id="latitude" name="latitude" value="<%=request.getAttribute("latitude") %>"/>
<input type="hidden" id="longitude" name="longitude" value="<%=request.getAttribute("longitude") %>"/>

<table width="100%" border="0" cellpadding="10">
  <tr>
    <td colspan="2" bgcolor="#b5dcb3"  style="margin-left:20px">
      <h1>Quell Your Hunger</h1>
      <p>If specifying address, please enter a combination of address, neighborhood, city, state or zip code.</p>	
      <p>
    	   <input type="radio" id="id_geo" name="location" value="geoLocation" onClick="disableOther(this)" > Use My Location  
		   <input type="radio" id="id_user" name="location" value="userLocation" onClick="disableOther(this)"  checked="checked"> Specify Address  
		   <input type="text" id="id_address" name="userAddress" size="50" style="margin-right: 50px"/>
		   Keyword:<input type="text" name="user_id"  size="50"/>
		   <input type="submit" name="search" value="Search" style="margin-left: 20px"/>
		   <a href="#" onclick="toggleFilter()">Filters</a>
    
      </p>
      
      <!-- placing filters in div with id, to be used by togglefilter() -->
      <div id="id_filters" style="display:none;">
      <table border="1"  width="100%" id="filter-table">
		<tr>
		  <th width="33%">Location</th>
		  <th width="33%">Search By</th>
		  <th width="33%">Sort By</th>
		</tr>
		<tr>
		  <td>
		    <label for="distanceRadius" >Radius:</label>
		    <select name="distanceRadius">
			  <option value="5">5 miles</option>
			  <option value="10">10 miles</option>
			  <option value="15">15 miles</option>
			  <option value="25">25 miles</option>
			</select>
		  </td>
		  <td> <!-- use requests to assigned checked values, to maintain filter selections for succeeding searches -->
		  <%
			String hotNew_checked = (request.getAttribute("hotNew") != null && request.getAttribute("hotNew").equals("hot_and_new"))? "checked":"";
			String offerDeal_checked = (request.getAttribute("offerDeal") != null && request.getAttribute("offerDeal").equals("deals"))? "checked":"";
			String delivery_checked = (request.getAttribute("delivery") != null && request.getAttribute("delivery").equals("delivery"))? "checked":"";
			String cashback_checked = (request.getAttribute("cashback") != null && request.getAttribute("cashback").equals("cashback"))? "checked":"";
		  %>
		   <!-- make openNow checked by default -->
		   <input type="checkbox" name="openNow" value="true" checked="checked"> Open Now <br>
		   <input type="checkbox" name="hotNew" value="hot_and_new" <%=hotNew_checked %>> Hot &amp; New <br>
		   <input type="checkbox" name="offerDeal" value="deals" <%=offerDeal_checked %> > Offering Deals <br>
		   <input type="checkbox" name="delivery" value="delivery" <%=delivery_checked %> > Delivery <br>
		   <input type="checkbox" name="cashback" value="cashback" <%=cashback_checked %> > Cashback <br>
		  </td>	  
		  <td>
		   <!-- make distance checked by default -->
		   <input type="radio" name="sorting" value="best_match"> Best Match <br>
		   <input type="radio" name="sorting" value="distance" checked="checked"> Distance <br> 
		   <input type="radio" name="sorting" value="rating"> Rating <br> 
		   <input type="radio" name="sorting" value="review_count" > Review Count <br> 
	      </td>
		</tr>
	  </table>
      </div>
      <br />  
      
    </td>
  </tr>
  <tr valign="top">
    <td bgcolor="#eee" width="50%" height="300">
      <b>Results</b><br />
      <div id="search_results" style="margin:0 ;height:500px;border:1px solid black;vertical-align: top; overflow-y: scroll;">
      <table width="100%" cellpadding="10">
      <!-- printing results -->
	  <%
      if(null!=request.getAttribute("businesses"))
      {
    	JSONArray jsonArray = (JSONArray)request.getAttribute("businesses");
        JSONArray markers = new JSONArray();
        JSONArray tmp = new JSONArray();
        //stores user location first, in the array
        tmp.put("My Location");
        tmp.put(request.getAttribute("latitude"));
        tmp.put(request.getAttribute("longitude"));
        tmp.put(1);
        markers.put(tmp);
        
        for(int i=0; i<jsonArray.length(); i++)
        {
        	JSONObject businessObj =jsonArray.getJSONObject(i);
 			//place business location into array
        	tmp = new JSONArray();
            tmp.put(businessObj.get("name"));
            tmp.put(businessObj.getJSONObject("coordinates").getDouble("latitude"));
            tmp.put(businessObj.getJSONObject("coordinates").getDouble("longitude"));
            tmp.put(i+2);
            //add tmp array into markers array
            markers.put(tmp);
            //store distance in miles, rouded to 2 decimal places
            double dist = Math.round((businessObj.getDouble("distance")/1609.34)*100)/100;
            //split address into two lines, easier to print
            JSONArray dsiplayAddress = businessObj.getJSONObject("location").getJSONArray("display_address");
            String add1 = (dsiplayAddress.length() == 1)?dsiplayAddress.getString(0):"";
            String add2 = (dsiplayAddress.length() == 2)?dsiplayAddress.getString(1):"";
	   %>        	
			<!-- print info in cell, two divs, on click shows infoWindow -->
	    	<tr bgcolor="<%= (i % 2) == 0 ? "#E6F1F5" : "#FFFFFF" %>">
			  <td> 
			    <div  onclick="showInfoWindow('<%=i+1 %>')">
		          <div style="width:25px;float:left;display:inline-block;">
		            <%=i+1 %>.
		          </div>
			      <div id="business<%=i %>"  style="margin-left:50px;">
			  	    <a href="<%=businessObj.getString("url") %>"  target="_blank"><%=businessObj.get("name")%> </a> (<%=dist %> mi)
			        <%=add1%> <br>
			        <%=add2%> <br>
			        <%=businessObj.get("display_phone")%> <br>
			        Rating: <%=businessObj.get("rating") %> <span style="margin-left:20px">   Review Count: <%=businessObj.get("review_count") %></span>
			  	  </div>
			    </div>		
			  </td>		
			</tr> 
		<%      
        }
        
        System.out.println(markers.toString());
        //if no results are found
        if(jsonArray.length()==0)
        {
		%>  
			<font color="red"> No results were found. Please make your search less specific. </font>    
		<%
		}

		%>
		<!-- hidden input for markers -->
		<input type="hidden" id="id_markers" name="markers" value='<%=markers.toString().replaceAll("'", "&apos;") %>'/>
<%           
      }
%>      
	  </table>
      </div>
    </td>
    <td width="50%" height="300" bgcolor="#eee">
      <div id="basic-map" style="margin:0 ;height:520px;border:1px solid black;vertical-align: top;">
    	<div id="map_canvas" style="width:100%;height:520px;"></div>
	  </div>         
    </td>
  </tr>
  <tr>
    <td colspan="2" bgcolor="#b5dcb3">
      <center>Created by Srushti Karra</center>
    </td>
  </tr>
</table>
</form>
</body>
</html> 