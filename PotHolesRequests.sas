proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Pot_Holes_Reported.csv"
	out = PotHoles replace
	dbms = csv;
run;

data PotHoles(rename=(NUMBER_OF_POTHOLES_FILLED_ON_BLO=PotHoles_Filled));
   set PotHoles;
   RQYear = YEAR(Creation_Date);
   RQMonth = MONTH(Creation_Date);
   DaysToComplete = DATDIF(Creation_Date, Completion_Date, 'act/act') ;
   if Type_of_Service_Request = 'Pothole in Street' 
      then Type_of_Service_Request = 'Pot Hole in Street';
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

data PotHoles;
	set PotHoles;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           PotHoles_Filled = "Number of Potholes Filled"
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
   text="Chicago 311 Service Requests^nPotHoles^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/PotHolesRequestsReport.pdf" style=Journal;
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
proc freq data=PotHoles;
	tables Type_of_Service_Request / missprint;
run;

proc freq data=PotHoles;
	tables Most_Recent_Action / missprint;
run;

*WHEN;
proc tabulate data=PotHoles;
	class RQYear;
	var PotHoles_Filled;
	table RQYear, PotHoles_Filled * (N Mean Median Min Max);
	Title "Potholes Filled by Year";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQMonth groupdisplay=cluster;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Month";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / response=PotHoles_Filled group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Type of Service Request and Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / response=PotHoles_Filled group = RQYear;
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Most Recent Action and Year";	
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / response=PotHoles_Filled group = RQYear;
	where Most_Recent_Action ^= 'Pothole Patched';
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Most Recent Action (w/o Highest Outlier) and Year";	
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / response=PotHoles_Filled group = RQYear;
	where Most_Recent_Action ^= 'Pothole Patched' AND Most_Recent_Action ^= 'CDOT Street Cut';
	yaxis valuesformat = comma10.0;
	Title "Potholes Filled by Most Recent Action (w/o Highest 2 Outliers) and Year";	
run;


ods pdf style = JOURNAL;
*WHERE;
proc tabulate data=PotHoles order=FREQ;
	class RQYear Community_Area;
	var PotHoles_Filled;
	table Community_Area, PotHoles_Filled * N * RQYear;
	Title "Potholes Filled by Community Area";
run;

proc freq data= PotHoles order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;	
	where Community_Area in (25, 24, 22, 2, 28);
	yaxis valuesformat = comma10.0;
	Title "Potholes RQs for Top 5 Community Areas by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	where Community_Area in (39, 54, 37, 47, 36);
	yaxis valuesformat = comma10.0;	
	Title "Potholes RQs for Bottom 5 Community Areas by Year";
run;

ods pdf style = JOURNAL;
proc freq data= PotHoles order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (41, 32, 23, 19, 45);
	yaxis valuesformat = comma10.0;
	Title "Potholes RQs in Top 5 Wards";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (4, 44, 48, 22, 46);
	yaxis valuesformat = comma10.0;
	Title "Potholes RQs in Bottom 5 Wards";
run;

*HOW;
proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear groupdisplay=cluster stat=mean;
	Title "Mean Days To Complete by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=PotHoles_Filled group = RQYear groupdisplay=cluster stat=mean;
	format PotHoles_Filled comma10.0;
	Title "Mean Potholes Filled by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=PotHoles_Filled group = RQYear groupdisplay=cluster stat=median;
	format PotHoles_Filled comma10.0;	
	Title "Median Potholes Filled by Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	format PotHoles_Filled comma10.0;
	Title "Median Potholes Filled by Status and Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / response=PotHoles_Filled group = RQYear groupdisplay=cluster stat=median;
	format PotHoles_Filled comma10.0;
	Title "Median Potholes Filled by Type of Service Request and Year";
run;

proc sgplot data = PotHoles;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / response=PotHoles_Filled group = RQYear stat=median;
	format PotHoles_Filled comma10.0;	
	Title "Median Potholes Filled by Most Recent Action and Year";
run;

ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete), .01) as Avg_DaysToComplete,
		   round(mean(PotHoles_Filled), .01) as Avg_PotHoles_Filled
	from PotHoles
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
	       loc.Avg_PotHoles_Filled,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/PotHolesRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;

