proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Alley_Lights_Out.csv"
	out = AlleyLights replace
	dbms = csv;
run;

data AlleyLights;
   set AlleyLights;
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   if RQYear >= 2011 and RQYear <= 2016;
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

data AlleyLights;
	set AlleyLights;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
	 	   DaysToComplete ="Days to Complete Request"
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

/* Create a data set containing the desired title text */
data mytitle;
   text="Chicago 311 Service Requests^nAlley Lights^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/AlleyLightsRequestsReport.pdf" style=Journal;
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
proc freq data=AlleyLights;
	tables Type_of_Service_Request;
run;

ods pdf style = HTMLBLUE;
proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Status Request by Year";
run;

ods pdf style = JOURNAL;
* WHEN;
proc tabulate data=AlleyLights;
	class RQYear Type_of_Service_Request;
	table RQYear, Type_of_Service_Request*N;
run;

ods pdf style = HTMLBLUE;
proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Alley Lights RQs by Year";
run;

proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;	
	Title "Alley Lights RQs by Month";
run;

proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Type of Service Request by Year";
run;

proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;	
	Title "Type of Service Request by Month";
run;

ods pdf style = JOURNAL;
* WHERE;
proc freq data= AlleyLights order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
* WHERE;
proc sgplot data = AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (25, 49, 71, 56, 53);
	yaxis valuesformat = comma10.0;
	Title "Alley Lights RQs in Top 5 Community Areas";
run;

proc sgplot data = AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (36, 33, 32, 54, 76);
	yaxis valuesformat = comma10.0;	
	Title "Alley Lights RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= AlleyLights order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (13, 34, 23, 8, 21);
	yaxis valuesformat = comma10.0;
	Title "Alley Lights RQs in Top 5 Wards";
run;

proc sgplot data = AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (44, 43, 48, 46, 42);
	yaxis valuesformat = comma10.0;
	Title "Alley Lights RQs in Bottom 5 Wards";
run;

* HOW;
ods pdf style = JOURNAL;
proc tabulate data=AlleyLights;
	class RQYear;
	var DaysToComplete;
	table RQYear, DaysToComplete*(N Mean Median Min Max);
run;

ods pdf style = HTMLBLUE;
proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=mean;
	Title "Mean Days To Complete by Year";
run;

proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Year";
run;

proc sgplot data=AlleyLights;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response = DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Status and Year";
run;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete),.01) as Avg_DaysToComplete
	from AlleyLights
	group by ward	
	order by ward;
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.Rep_Location, loc.RQCount, loc.Avg_DaysToComplete,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/AlleyLightsRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;