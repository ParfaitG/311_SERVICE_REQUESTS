proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Graffiti_Removal.csv"
	out = Graffiti replace
	dbms = csv;
run;

data Graffiti(rename=(What_Type_of_Surface_is_the_Graf=Surface_Type
                      Where_is_the_Graffiti_located_=Graffiti_Located));
   set Graffiti;
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

data Graffiti;
	set Graffiti;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Graffiti_Located = "Location of Graffiti"
           Surface_Type = "Surface Type"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Abandoned_Days = "Vehicle Abandoned Days"
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
   text="Chicago 311 Service Requests^nGraffiti Removal^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/GraffitiRequestsReport.pdf" style=Journal; 
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
proc freq data= Graffiti; 
	tables Graffiti_Located / missing; 
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Graffiti_Located / group = RQYear;
	yaxis valuesformat = comma10.0;	
	Title "Graffiti Location by Year";
run;

proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Surface_Type / group = RQYear;
	yaxis valuesformat = comma10.0;	
	Title "Surface Type by Year";
run;

ods pdf style = JOURNAL;
proc freq data= Graffiti; 
	tables Graffiti_Located * Surface_Type / missing;
	Title "Graffiti Location by Surface Type";
run;

ods pdf style = HTMLBLUE;
* WHEN;
proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Graffiti by Year";
run;

proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;
	Title "Graffiti by Month";
run;

ods pdf style = JOURNAL;
proc freq data= Graffiti; 
	tables Surface_Type * RQYear  / missprint; 
	Title "Surface Type by Year";
run;

proc freq data= Graffiti; 
	tables Graffiti_Located * RQYear / missprint; 
	Title "Graffiti Location by Year";
run;

proc freq data= Graffiti order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
* WHERE;
proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (30, 24, 22, 31, 58);
	yaxis valuesformat = comma10.0;
	Title "Graffiti RQs in Top 5 Community Areas";
run;

proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (50, 9, 36, 47, 54);
	yaxis valuesformat = comma10.0;	
	Title "Graffiti RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= Graffiti order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (14, 1, 25, 12, 35);
	yaxis valuesformat = comma10.0;
	Title "Graffiti RQs in Top 5 Wards";
run;

proc sgplot data = Graffiti;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (8, 19, 34, 6, 21);
	yaxis valuesformat = comma10.0;
	Title "Graffiti RQs in Bottom 5 Wards";
run;

ods pdf style = JOURNAL;
* HOW;
proc freq data= Graffiti; 
	tables Status * RQYear / missing; 
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Graffiti (where = (DaysToComplete > 0)); 
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group=RQYear stat=mean;
	Title "Mean Days To Complete Request by Year";
run;

proc sgplot data = Graffiti (where = (DaysToComplete > 0)); 
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group=RQYear stat=median;
	Title "Median Days To Complete Request by Year";
run;

proc sgplot data = Graffiti (where = (DaysToComplete > 0)); 
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Surface_Type / response=DaysToComplete group=RQYear stat=median;
	Title "Median Days To Complete by Surface Type";
run;

proc sgplot data = Graffiti (where = (DaysToComplete > 0)); 
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Graffiti_Located / response=DaysToComplete group=RQYear stat=median;
	Title "Median Days To Complete by Graffiti Locaiton";
run;

ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete),.01) as Avg_DaysToComplete
	from Graffiti
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
	       loc.Avg_DaysToComplete,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/GraffitiRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;



