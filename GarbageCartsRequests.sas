proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Garbage_Carts.csv"
	out = GarbageCarts replace
	dbms = csv;
run;

data GarbageCarts;
   set GarbageCarts;
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

data GarbageCarts;
	set GarbageCarts;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Number_of_Black_Carts_Delivered = "Number of Black Carts Delivered"
	 	   DaysToComplete ="Days to Complete Request"
	 	   Most_Recent_Action = "Most Recent Action"
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
   text="Chicago 311 Service Requests^nGarbage Carts^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/GarbageCartsRequestsReport.pdf" style=Journal;
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
proc freq data=GarbageCarts;
	tables Current_Activity;
run;

proc freq data=GarbageCarts;
	tables Most_Recent_Action;
run;

proc freq data=GarbageCarts;
	tables Type_of_Service_Request * RQYear / missprint;
run;

*WHEN;
proc tabulate data=GarbageCarts;	
	class RQYear;
	var Number_of_Black_Carts_Delivered;
	table Number_of_Black_Carts_Delivered * Mean * RQYear;
	Title "Mean Number of Black Carts Delivered by Year";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster stat = mean;
	yaxis valuesformat = comma10.0;
	Title "Garbage Carts RQs by Year";
run;

proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQMonth / group = RQYear groupdisplay=cluster stat = mean;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;	
	Title "Garbage Carts RQs by Month";
run;

proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response = Number_of_Black_Carts_Delivered group = RQYear groupdisplay=cluster stat = mean;
	where Number_of_Black_Carts_Delivered < 5000;
	yaxis valuesformat = comma10.0;		
	Title "Mean Black Carts Delivered by Status and Year";
run;

proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Service Request Type by Year";
run;

ods pdf style = JOURNAL;
*WHERE;
proc freq data= GarbageCarts order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (25, 71, 23, 66, 49);
	yaxis valuesformat = comma10.0;
	Title "GarbageCarts RQs in Top 5 Community Areas";
run;

proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area IN (33, 76, 54, 36, 32);
	yaxis valuesformat = comma10.0;	
	Title "GarbageCarts RQs in Bottom 5 Community Areas";
run;

ods pdf style = JOURNAL;
proc freq data= GarbageCarts order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (21, 18, 37, 24, 19);
	yaxis valuesformat = comma10.0;
	Title "Garbage Carts RQs in Top 5 Wards";
run;

proc sgplot data = GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (4, 49, 48, 46, 42);
	yaxis valuesformat = comma10.0;
	Title "Garbage Carts RQs in Bottom 5 Wards";
run;

ods pdf style = JOURNAL;
*HOW;
proc tabulate data=GarbageCarts;	
	class Status RQYear;
	var Number_of_Black_Carts_Delivered;
	table Status, Number_of_Black_Carts_Delivered * Mean * RQYear;
run;

proc tabulate data=GarbageCarts;
	class RQYear;
	var DaysToComplete;
	table RQYear, DaysToComplete*(N Mean Median Min Max);
run;

ods pdf style = HTMLBLUE;
proc sgplot data=GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=mean;	
	Title "Mean Days To Complete by Year";
run;

proc sgplot data=GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Year";
run;

proc sgplot data=GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = Number_of_Black_Carts_Delivered group = RQYear groupdisplay=cluster stat=mean;
	format Number_of_Black_Carts_Delivered comma10.0;	
	Title "Mean Number_of_Black_Carts_Delivered by Year";
run;

proc sgplot data=GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response = Number_of_Black_Carts_Delivered group = RQYear groupdisplay=cluster stat=median;
	format Number_of_Black_Carts_Delivered comma10.0;
	Title "Median Number_of_Black_Carts_Delivered by Year";
run;

proc sgplot data=GarbageCarts;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response = DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Status and Year";
run;

ods pdf close;

 
 
* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete),.01) as Avg_DaysToComplete,
		   mean(Number_of_Black_Carts_Delivered) as Avg_BlackCarts
	from GarbageCarts
	group by ward	
	order by ward;
quit;

proc univariate data=LonLatData noprint;
	var RQCount;
	output out=RankPctl pctlpts=33 66 pctlpre=P;
run;

proc sql;
	create table jsonData as
	select loc.Ward, loc.RQCount, loc.Rep_Location,
	       loc.Avg_DaysToComplete, loc.Avg_BlackCarts,
	       case when loc.RQCount > r.p66 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount <= r.p33 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/GarbageCartsRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;