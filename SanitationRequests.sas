proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Sanitation_Code_Complaints.csv"
	out = Sanitation replace
	dbms = csv;
run;

data Sanitation(rename=(What_is_the_Nature_of_this_Code=Nature_of_Code));
   set Sanitation;
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

data Sanitation;
	set Sanitation;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Nature_of_Code = "Nature of Code"
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
   text="Chicago 311 Service Requests^nSanitation Code Complaints^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/SanitationRequestsReport.pdf" style=Journal;
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
proc freq data = Sanitation;
	tables Nature_of_Code / missing;
run;

proc freq data = Sanitation;
	tables Type_of_Service_Request / missing;
run;

proc freq data = Sanitation;
	tables Status / missing;
run;

ods pdf style = HTMLBLUE;
* WHEN;
proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Status by Year";
run;

proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Nature_of_Code / group = RQYear groupdisplay=cluster;
	Title "Nature of Code by Year";
run;

proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster stat = mean;
	yaxis valuesformat = comma10.0;
	Title "Sanitation RQs by Year";
run;

proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQMonth / group = RQYear groupdisplay=cluster stat = mean;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;	
	Title "Sanitation RQs by Month";
run;

ods pdf style = JOURNAL;
* WHERE;
proc freq data= Sanitation order = freq; 
	tables Community_Area * RQYear / missprint; 
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (25, 24, 71, 22, 7);
	yaxis valuesformat = comma10.0;
	Title "Sanitation RQs in Top 5 Community Areas";
run;

proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (47, 37, 76, 36, 54);
	yaxis valuesformat = comma10.0;
	Title "Sanitation RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= Sanitation order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (6, 21, 32, 17, 7);
	yaxis valuesformat = comma10.0;
	Title "Sanitation RQs in Top 5 Wards";
run;

proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (12, 49, 42, 4, 48);
	yaxis valuesformat = comma10.0;
	Title "Sanitation RQs in Bottom 5 Wards";
run;

ods pdf style = JOURNAL;
* HOW;
proc tabulate data = Sanitation;
	class RQYear Nature_of_Code;
	var DaysToComplete;
	table RQYear, DaysToComplete * (N Min Max Mean Median);
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Nature_of_Code / response = DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Days to Complete by Nature of Code and Year";
run;

proc sgplot data=Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=mean;	
	Title "Mean Days To Complete by Year";
run;

proc sgplot data=Sanitation;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Year";
run;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete), .01) as Avg_DaysToComplete
	from Sanitation
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
	out = "/folders/myfolders/Maps/Data/SanitationRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;

 
 
 