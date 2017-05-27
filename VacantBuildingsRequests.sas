proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Vacant_and_Abandoned_Buildings.csv"
	out = VacantBuildings replace
	dbms = csv;
run;

data VacantBuildings(rename=(ANY_PEOPLE_USING_PROPERTY___HOM=People_Using
                             IS_BUILDING_OPEN_OR_BOARDED_=Open_Or_Boarded
                             IF_THE_BUILDING_IS_OPEN__WHERE=Graffiti_Located
                             IS_THE_BUILDING_CURRENTLY_VACANT=Currently_Vacant
                             IS_THE_BUILDING_DANGEROUS_OR_HAZ=Dangerous_Hazard
                             IS_THE_BUILDING_VACANT_DUE_TO_FI=Due_To_Fire
                             LOCATION_OF_BUILDING_ON_THE_LOT=Location_Lot
                             DATE_SERVICE_REQUEST_WAS_RECEIVE=Creation_Date));                            
   
   set VacantBuildings;
   RQYear = YEAR(DATE_SERVICE_REQUEST_WAS_RECEIVE);
   RQMonth = MONTH(DATE_SERVICE_REQUEST_WAS_RECEIVE);
   StreetAddress = catx(' ', ADDRESS_STREET_NAME, ADDRESS_STREET_SUFFIX);
   
   if RQYear >= 2011 and RQYear <= 2016;
run;

data VacantBuildings;
	set VacantBuildings;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Currently_Vacant = "Currently Vacant"
		   Dangerous_Hazard = "Dangerous Hazard"
		   Graffiti_Located = "Graffiti Located"
		   Location_Lot = "Location Lot"
           Due_To_Fire = "Due to Fire"
           Open_Or_Boarded = "Open or Boarded"
           People_Using = "People Using"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Community_Area = "Chicago Community Area"
	 	   Ward = "Chicago Ward"
	 	   Current_Activity = "Current Activity"
	 	   SERVICE_REQUEST_TYPE = "Type of Service Request"; 
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
   text="Chicago 311 Service Requests^nVacant Buildings^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/VacantBuildingsRequestsReport.pdf" style=Journal notoc startpage=no; 
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

*WHAT;
proc freq data=VacantBuildings;	
	tables Open_Or_Boarded / missprint;
run;

proc freq data=VacantBuildings;	
	tables Currently_Vacant / missprint;
run;

proc freq data=VacantBuildings;	
	tables Dangerous_Hazard / missprint;
run;

proc freq data=VacantBuildings;	
	tables People_Using * RQYear / missprint;
run;

ods pdf style = HTMLBLUE;
proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Open_Or_Boarded / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Open or Boarded by Year";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Currently_Vacant / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Currently Vacant by Year";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Due_To_Fire / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Due to Fire by Year";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar People_Using / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "People Using by Year";
run;

* WHEN;
proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Vacant Buildings Requests by Year";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;
	Title "Vacant Buildings Requests by Month";
run;

ods pdf style = JOURNAL;
* WHERE;
proc freq data = VacantBuildings order=freq;
	table Community_Area * RQYear / missing;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (67, 68, 25, 49, 46);
	yaxis valuesformat = comma10.0;
	Title "Top 5 Community Area by Year";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (13, 32, 9, 34, 76);
	yaxis valuesformat = comma10.0;
	Title "Bottom 5 Community Area by Year";
run;

ods pdf style = JOURNAL;
proc freq data= VacantBuildings order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (17, 34, 16, 28, 15);
	yaxis valuesformat = comma10.0;
	Title "Vacant Buildings RQs in Top 5 Wards";
run;

proc sgplot data = VacantBuildings;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (46, 48, 44, 49, 42);
	yaxis valuesformat = comma10.0;
	Title "Vacant Buildings RQs in Bottom 5 Wards";
run;

* HOW;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   sum(case when Open_Or_Boarded = 'Boarded' then 1 else 0 end) as BoardedCount,
		   sum(case when People_Using = 'TRUE' then 1 else 0 end) as PeopleUsingCount,
		   sum(case when Due_To_Fire = 'T' then 1 else 0 end) as DueToFireCount,
		   sum(case when Currently_Vacant = 'Occupi' then 1 else 0 end) as OccupiedCount
	from VacantBuildings
	group by ward	
	order by ward;
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.Rep_Location, loc.RQCount,
		   BoardedCount, PeopleUsingCount, DueToFireCount, OccupiedCount,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/VacantBuildingsRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;



