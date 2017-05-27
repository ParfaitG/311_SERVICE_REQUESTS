proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Abandoned_Vehicles.csv"
	out = Vehicles replace
	dbms = csv;
run;

data Vehicles (rename=(How_Many_Days_Has_the_Vehicle_Be=Abandoned_Days));
   set Vehicles;
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   
   if RQYear >= 2011 and RQYear <= 2016;
run;

data Vehicles;
	set Vehicles;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Most_Recent_Action = "Most Recent Action"
           Vehicle_Make_Model = "Vehicle Make/Model"
           Vehicle_Color = "Vehicle Color"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Abandoned_Days = "Vehicle Abandoned Days"
	 	   Current_Activity = "Current Activity"
	 	   Community_Area = "Chicago Community Area"	 	   
	 	   Ward = "Chicago Ward"
	 	   Type_of_Service_Request = "Type of Service Request"; 
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
   text="Chicago 311 Service Requests^nAbandoned Vehicles^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/VehicleRequestsReport.pdf" style=Journal; 
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
proc freq data= Vehicles; 
	tables Vehicle_Make_Model / missing; 
run;

proc freq data= Vehicles; 
	tables Vehicle_Color / missing; 
run;

proc freq data= Vehicles; 
	tables Most_Recent_Action / missing; 
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Most Recent Action by Year";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Status by Year";
run;

* WHEN;
ods pdf style = HTMLBLUE;
proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Vehicle Requests by Year";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;
	Title "Vehicle Requests by Month";
run;

ods pdf style = JOURNAL;
proc freq data= Vehicles; 
	tables Current_Activity * RQYear / missing; 
	Title "Current Activity by Year";	
run;

proc tabulate data= Vehicles; 
	class RQYear;
	var Abandoned_Days;
	table RQYear, Abandoned_Days*(N Mean Median Min Max);
	Title "Abandoned Days by Year";		
run;

proc tabulate data= Vehicles; 
	class RQYear;
	var DaysToComplete;
	table RQYear, DaysToComplete*(N Mean Median Min Max);
	Title "Days to Complete by Year";		
run;

* WHERE;
proc freq data= Vehicles order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (15, 16, 19, 25, 24);
	yaxis valuesformat = comma10.0;
	Title "Vehicle RQs in Top 5 Community Areas";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (36, 33, 37, 47, 54);
	yaxis valuesformat = comma10.0;	
	Title "Vehicle RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= Vehicles order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (45, 36, 38, 13, 11);
	yaxis valuesformat = comma10.0;
	Title "Vehicle RQs in Top 5 Wards";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (42, 19, 46, 44, 43);
	yaxis valuesformat = comma10.0;
	Title "Vehicle RQs in Bottom 5 Wards";
run;

* HOW;
proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear stat=mean groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Mean Days To Complete by Year";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear stat=median groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Median Days To Complete by Year";
run;

proc sgplot data = Vehicles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=Abandoned_Days group = RQYear stat=median groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Median Abandoned Days by Year";
run;

proc sgplot data = Vehicles;
	format DaysToComplete comma6.;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Current_Activity / response=DaysToComplete group = RQYear stat=median groupdisplay=cluster;
	Title "Median Days to Complete by Current Activity and Year";
run;

proc sgplot data = Vehicles;
	format Abandoned_Days comma6.;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Current_Activity / response=Abandoned_Days group = RQYear stat=mean  groupdisplay=cluster;
	yaxis values=(0 to 50 by 5);
	where Abandoned_Days >= 0 and Abandoned_Days <= 10000;
	Title "Median Abandoned Days by Current Activity and Year";	
run;

ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(avg(Abandoned_Days),.01) as Avg_AbandonedDays,
		   round(avg(DaysToComplete),.01) as Avg_DaysToComplete
	from Vehicles
	group by ward;	
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.Rep_Location, loc.RQCount, loc.Avg_DaysToComplete, loc.Avg_AbandonedDays, loc.Avg_DaysToComplete,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/VehicleRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;

