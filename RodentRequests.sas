proc import
	datafile = "/folders/myfolders/ServiceRequests/311_Service_Requests_-_Rodent_Baiting.csv"
	out = Rodents replace
	dbms = csv;
run;

data Rodents;
   set Rodents;
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

data Rodents;
	set Rodents;
	
  	label  RQYear  ="Year of Request"
           RQMonth ="Month of Request"
           Number_of_Premises_Baited = "Number of Baited Premises"
           Number_of_Premises_with_Garbage = "Number of Premises with Garbage"
           Number_of_Premises_with_Rats = "Number of Premises with Rats"
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
   text="Chicago 311 Service Requests^nRodent Baiting^n2011-2016";
run;

ods pdf file="/folders/myfolders/Reports/RodentRequestsReport.pdf" style=Journal;
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
proc freq data=Rodents;
	tables Type_of_Service_Request / missprint;
run;

proc freq data=Rodents;
	tables Current_Activity / missprint;
run;

proc freq data=Rodents;
	tables Most_Recent_Action / missprint;
run;

proc freq data=Rodents;
	tables Status / missprint;
run;

*WHEN;
ods pdf style = HTMLBLUE;
proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / group = RQYear groupdisplay=cluster stat = mean;
	yaxis valuesformat = comma10.0;
	Title "Rodents RQs by Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQMonth / group = RQYear groupdisplay=cluster stat = mean;
	format RQMonth mn_name.;
	yaxis valuesformat = comma10.0;	
	Title "Rodents RQs by Month";
run;

ods pdf style = JOURNAL;
proc tabulate data=Rodents;
	class RQYear;
	var Number_of_Premises_Baited;
	tables RQYear, Number_of_Premises_Baited * (N Mean Median Min Max);
	Title "Number of Rat Baited Premises by Year";	
run;

proc tabulate data=Rodents;
	class RQYear;
	var Number_of_Premises_with_Garbage;
	tables RQYear, Number_of_Premises_with_Garbage * (N Mean Median Min Max);
	Title "Number of Premises with Garbage by Year";		
run;

proc tabulate data=Rodents;
	class RQYear;
	var Number_of_Premises_with_Rats;
	tables RQYear, Number_of_Premises_with_Rats * (N Mean Median Min Max);
	Title "Number of Premises with Rats by Year";		
run;

*WHERE;
proc freq data= Rodents order=freq; 
	tables Community_Area * RQYear  / missprint;
	Title "Community Area by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	where Community_Area in (6, 2, 22, 24, 7);
	Title "Rodents RQs for Top 5 Community Areas";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Community_Area / group = RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;
	where Community_Area in (47, 55 36, 76, 54);
	Title "Rodents RQs for Bottom 5 Community Areas";	
run;

ods pdf style = JOURNAL;
proc freq data= Rodents order=freq; 
	tables Ward * RQYear / missprint; 
	Title "Ward by Year (Descending)";
run;

ods pdf style = HTMLBLUE;
proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (32, 50, 35, 13, 1);
	yaxis valuesformat = comma10.0;
	Title "Rodents RQs in Top 5 Wards";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Ward / group = RQYear groupdisplay=cluster;
	where Ward IN (42, 9, 4, 7, 10);
	yaxis valuesformat = comma10.0;
	Title "Rodents RQs in Bottom 5 Wards";
run;

*HOW;
proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Type_of_Service_Request / group=RQYear groupdisplay=cluster;
	yaxis valuesformat = comma10.0;	
	Title "Type of Service Request by Year";	
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=Number_of_Premises_Baited group = RQYear groupdisplay=cluster stat=mean;
	where Number_of_Premises_Baited < 5000;
	Title "Mean Number of Premises Baited by Status and Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=Number_of_Premises_with_Garbage group = RQYear groupdisplay=cluster stat=mean;
	format Number_of_Premises_with_Garbage comma10.0;
	where Number_of_Premises_Baited < 2100;
	Title "Mean Number of Premises with Garbage by Status and Year";	
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=Number_of_Premises_with_Rats group = RQYear groupdisplay=cluster stat=mean;
	format Number_of_Premises_with_Rats comma10.0;
	Title "Mean Number of Premises with Rats by Status and Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear groupdisplay=cluster stat=mean;
	Title "Mean Days To Complete by Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar RQYear / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Status / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Status and Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Current_Activity / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Current Activity and Year";
run;

proc sgplot data = Rodents;
	styleattrs datacolors = (&colors_list) datacontrastcolors = (&colors_list);
	vbar Most_Recent_Action / response=DaysToComplete group = RQYear groupdisplay=cluster stat=median;
	Title "Median Days To Complete by Most Recent Action and Year";
run;
ods pdf close;


* GEO CODES SUMMARY;
proc sql;
    create table LonLatData as
	select ward, max(location) as Rep_Location, count(*) as RQCount,
		   round(mean(DaysToComplete), .01) as Avg_DaysToComplete,
		   round(mean(Number_of_Premises_Baited), .01) as Avg_PremisedBaited, 
	       round(mean(Number_of_Premises_with_Garbage), .01) as Avg_PremiseswGarbage,
	       round(mean(Number_of_Premises_with_Rats), .01) as Avg_PremiseswRats
	from Rodents
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
	       loc.Avg_PremisedBaited, loc.Avg_PremiseswGarbage, Avg_PremiseswRats,
	       case when loc.RQCount <= r.p33 then 1
	            when loc.RQCount <= r.p66 and loc.RQCount > r.p33 then 2
	            when loc.RQCount > r.p66 then 3
	            else 0
	       end as RankGroup
	 from LonLatData loc, RankPctl r;
quit;

* OUTPUT JSON FOR MAPPING;
proc json
	out = "/folders/myfolders/Maps/Data/RodentRequestsMapPoints.json"
	pretty;
	export jsonData / nosastags;
run;


 
