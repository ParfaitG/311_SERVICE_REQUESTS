proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Street_Lights_-_All_Out.csv"
	out = StreetLightsAll replace
	dbms = csv;
run;

data StreetLightsAll;
   set StreetLightsAll;
   RQType = "All Out";
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   
   if RQYear >= 2011 and RQYear <= 2016;
run;


proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Street_Lights_-_One_Out.csv"
	out = StreetLightsOne replace
	dbms = csv;
run;

data StreetLightsOne;
   set StreetLightsOne;
   RQType = "One Out";
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   
   if RQYear >= 2011 and RQYear <= 2016;
run;

data StreetLights;
	set StreetLightsOne
	    StreetLightsAll;
run;

proc datasets library=Work;
   save StreetLights;
run;

proc format ;  
 value mn_name 1='Jan'
               2='Feb'
               3='Mar'
               4='Apr'
               5='May'
               6='Jun'
               7='Jul'
               8='Aug'
               9='Sep'
              10='Oct'
              11='Nov'
              12='Dec'
           other='';
run;

data StreetLights;
	set StreetLights;
	
  	label  RQType = "Request Type"
  	       RQYear  ="Year of Request"
           RQMonth ="Month of Request"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Current_Activity = "Current Activity"
	 	   Community_Area = "Chicago Community Area"
	 	   Ward = "Chicago Ward"
	 	   Type_of_Service_Request = "Type of Service Request"; 
run;

%let colors_list = cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2
                   cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868
                   cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd
                   cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2
                   cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868
                   cxc44e52 cx8172b2 cxccb974 cx64b5cd cx4c72b0 cx55a868 cxc44e52 cx8172b2 cxccb974 cx64b5cd;

/******** PDF ********/
options nodate;
ods escapechar="^";
ods noproctitle; 
title;

/* TITLE TEXT DATASET */
data mytitle;
   text="Chicago 311 Service Requests^nStreet Lights (All or One Out)^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/StreetLightsRequestsReport.pdf" style=Journal;
footnote h=6pt 'Source: City of Chicago, Open Data Portal' c=darkgray;

/* LOGO AND FOOTNOTE */
footnote1 j=c "Source: City of Chicago, Open Data Portal";
ods pdf text='^S={preimage="/folders/myfolders/Reports/ChiTitleIcon.png"}';
ods pdf text="^20n";

/* TITLE */
proc report data=mytitle nowd noheader style(report)={rules=none frame=void} 
     style(column)={font_weight=bold font_size=20pt just=c};
run;

ods pdf startpage=yes;
* WHAT;
proc freq data = StreetLights;
	table RQType / missing;
run;

proc freq data = StreetLights;
	table Type_of_Service_Request / missing;
run;

ods pdf style = HTMLBLUE;
* WHEN;
proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Street Lights RQs by Year";
run;

proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;		
	Title "Street Lights RQs by Month";
run;

proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;		
	Title "Type of Service_Request by Year";
run;

ods pdf style = JOURNAL;
* WHERE; 
proc freq data = StreetLights order = freq;
	table Community_Area * RQYear / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (25, 49, 71, 43, 70);
	yaxis valuesformat = comma10.0;	
	Title "Street Lights RQs in Top 5 Community Areas";
run;

proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (54, 76, 47, 37, 36);
	yaxis valuesformat = comma10.0;	
	Title "Street Lights RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= StreetLights order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (6, 21, 34, 10, 18);
	yaxis valuesformat = comma10.0;
	Title "Street Lights RQs in Top 5 Wards";
run;

proc sgplot data = StreetLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (33, 44, 48, 49, 46);
	yaxis valuesformat = comma10.0;
	Title "Street Lights RQs in Bottom 5 Wards";
run;

* HOW;
proc sgplot data = StreetLights;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days to Complete by Year";
run;

proc sgplot data = StreetLights;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete stat = median group = RQYear groupdisplay=cluster;
	Title "Median Days to Complete by Year";
run;

proc sgplot data = StreetLights;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / response = DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days to Complete by Year";
run;

proc sgplot data = StreetLights;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / response = DaysToComplete stat = sum group = RQYear groupdisplay=cluster;
	Title "Total Days to Complete by Year";
run;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   sum(case when RQType = 'All Out' then 1 else 0 end) as AllLightsCount,
		   sum(case when RQType = 'One Out' then 1 else 0 end) as OneLightCount,
		   round(mean(DaysToComplete), .01) as Avg_DaysToComplete
	from StreetLights
	group by ward	
	order by ward;
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.Rep_Location, loc.RQCount, loc.AllLightsCount,
	       loc.OneLightCount, loc.Avg_DaysToComplete,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/StreetLightsRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;

 
 