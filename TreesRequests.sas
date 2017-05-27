proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Tree_Debris.csv"
	out = Trees replace
	dbms = csv;
run;

data Trees(rename=(If_Yes__where_is_the_debris_loc=Tree_or_Debris_Located));
   set Trees;
   RQType = "Tree Debris";
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   
   if RQYear >= 2011 and RQYear <= 2016;
run;

proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Tree_Trims.csv"
	out = TreeTrims replace
	dbms = csv;
run;

data TreeTrims (rename=(Location_of_Trees=Tree_or_Debris_Located));
   set TreeTrims;
   RQType = "Tree Trims";
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   
   if RQYear >= 2011 and RQYear <= 2016;
run;

data Trees;
	set Trees
	    TreeTrims;
run;

proc datasets library=Work;
   save Trees;
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

data Trees;
	set Trees;
	
  	label  RQType = "Request Type"
  	       RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Tree_or_Debris_Located = "Location of Trees or Debris"
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
   text="Chicago 311 Service Requests^nTree Trims and Debris^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/TreesRequestsReport.pdf" style=Journal;
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
proc freq data=Trees;
	tables RQType / missing format=comma6.;
run;

proc freq data= Trees; 
	tables Tree_or_Debris_Located / missing format=comma6.; 
run;

proc freq data= Trees; 
	tables Type_of_Service_Request / missing format=comma6.; 
run;

proc freq data= Trees; 
	tables Current_Activity / missing format=comma6.; 
run;

ods pdf style = HTMLBLUE;
* WHEN;
proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Trees RQs by Year";
run;

proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;		
	Title "Trees RQs by Month";
run;

proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Tree_or_Debris_Located / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Location of Trees or Debris by Year";
run;

ods pdf style = JOURNAL;
proc freq data= Trees; 
	tables Status * RQYear / missing format=comma6.; 
run;

* WHERE;
proc freq data = Trees order = freq;
	tables Community_Area * RQYear / missing format=comma6.;	
	Title "Community Area by Year (Descending)";	
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;	
	where Community_Area IN (25, 49, 15, 53, 72);
	yaxis valuesformat = comma10.0;
	Title "Tree RQs in Bottom 5 Community Areas";
run;

proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;	
	where Community_Area IN (37, 36, 54, 76, 32);
	yaxis valuesformat = comma10.0;
	Title "Tree RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= Trees order=freq; 
	tables Ward * RQYear / missprint; 	
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (19, 34, 8, 41, 9);
	yaxis valuesformat = comma10.0;
	Title "Trees RQs in Top 5 Wards";
run;

proc sgplot data = Trees;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (43, 48, 49, 46, 42);
	yaxis valuesformat = comma10.0;
	Title "Trees RQs in Bottom 5 Wards";
run;

ods pdf style = JOURNAL;
* HOW;
proc tabulate data = Trees;
	class RQYear RQType;
	var DaysToComplete;
	tables RQType * RQYear, DaysToComplete * (N Mean Median Min Max);
	Title "Mean Days to Complete by RQ Type and Year";		
run;

proc tabulate data = Trees;
	class RQYear Tree_or_Debris_Located;
	var DaysToComplete;
	tables Tree_or_Debris_Located * RQYear, DaysToComplete * (N Mean Median Min Max);
	Title "Mean Days to Complete by Location of Trees/Debris and Year";	
run;

proc tabulate data = Trees;
	class RQYear Status;
	var DaysToComplete;
	tables Status * RQYear, DaysToComplete * (N Mean Median Min Max);
	Title "Mean Days to Complete by Status and Year";		
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Trees;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days to Complete by Year";
run;

proc sgplot data = Trees;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete stat = median group = RQYear groupdisplay=cluster;
	Title "Median Days to Complete by Year";
run;

proc sgplot data = Trees;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQType / response=DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days To Complete by RQ Type and Year";
run;

proc sgplot data = Trees;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Tree_or_Debris_Located / response=DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days To Complete by Location of Trees/Debris and Year";
run;

proc sgplot data = Trees;
	format DaysToComplete comma10.2;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=DaysToComplete stat = mean group = RQYear groupdisplay=cluster;
	Title "Mean Days To Complete by Status and Year";
run;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   sum(case when RQType = 'Tree Trims' then 1 else 0 end) as TreeTrimsCount,
		   sum(case when RQType = 'Tree Debris' then 1 else 0 end) as TreeDebrisCount,
		   round(mean(DaysToComplete), .01) as Avg_DaysToComplete
	from Trees
	group by ward	
	order by ward;
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.Rep_Location, loc.RQCount, loc.TreeTrimsCount, 
	       loc.TreeDebrisCount, loc.Avg_DaysToComplete,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/TreesRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;



